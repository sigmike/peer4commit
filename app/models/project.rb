class Project < ActiveRecord::Base
  has_many :deposits # todo: only confirmed deposits that have amount > paid_out
  has_many :tips
  has_many :collaborators

  validates :full_name, uniqueness: true, presence: true
  validates :github_id, uniqueness: true, presence: true

  def update_github_info repo
    self.github_id = repo.id
    self.name = repo.name
    self.full_name = repo.full_name
    self.source_full_name = repo.source.full_name rescue ''
    self.description = repo.description
    self.watchers_count = repo.watchers_count
    self.language = repo.language
    self.save!
  end

  def update_github_collaborators(github_collaborators)
    github_logins = github_collaborators.map(&:login)
    existing_logins = collaborators.map(&:login)

    collaborators.each do |collaborator|
      unless github_logins.include?(collaborator.login)
        collaborator.mark_for_destruction
      end
    end

    github_collaborators.each do |github_collaborator|
      unless existing_logins.include?(github_collaborator.login)
        collaborators.build(login: github_collaborator.login)
      end
    end

    save!
  end

  def github_url
    "https://github.com/#{full_name}"
  end

  def source_github_url
    "https://github.com/#{source_full_name}"
  end

  def new_commits
    begin
      commits = Timeout::timeout(90) do
        client = Octokit::Client.new \
          :client_id     => CONFIG['github']['key'],
          :client_secret => CONFIG['github']['secret'],
          :per_page      => 100
        client.commits(full_name).
          # Filter fake emails
          select{|c| c.commit.author.email =~ Devise::email_regexp }.
          # Filter commited after t4c project creation
          select{|c| c.commit.committer.date > self.deposits.first.created_at }.
          to_a
      end
    rescue Octokit::BadGateway, Octokit::NotFound, Octokit::InternalServerError,
           Errno::ETIMEDOUT, Net::ReadTimeout, Faraday::Error::ConnectionFailed => e
      Rails.logger.info "Project ##{id}: #{e.class} happened"
    rescue StandardError => e
      Airbrake.notify(e)
    end
    sleep(1)
    commits || []
  end

  def tip_commits
    commits = new_commits
    sha_set = CommitShaSet.new(commits)
    commit_modifiers = Hash.new(1.0)

    merges = commits.select { |c| c.parents.size > 1 }
    collaborator_logins = collaborators.map(&:login)

    merges.each do |commit|
      commit_modifiers[commit.sha] = 0

      if modifier = TipModifier.find_in_message(commit.commit.message)
        logger.info "Found modifier #{modifier.name} in commit #{commit.sha}"

        next unless collaborator_logins.include?(commit.author.try(:login))

        if merged_commits = sha_set.merged_commits(commit.sha)
          merged_commits.each do |modified_commit|
            commit_modifiers[modified_commit] = modifier.value
            logger.info "Applying modifier #{modifier} on commit #{modified_commit}"
          end
        end
      end
    end

    commits.each do |commit|
      modifier = commit_modifiers[commit.sha]
      if modifier > 0
        tip_for commit, modifier
      end
      update_attribute :last_commit, commit.sha
    end
  end

  def tip_for(commit, modifier = 1.0)
    email = commit.commit.author.email
    user = User.find_by email: email

    if (next_tip_amount > 0) &&
        Tip.find_by_commit(commit.sha).nil?

      # create user
      unless user
        generated_password = Devise.friendly_token.first(8)
          user = User.create({
          email: email,
          password: generated_password,
          name: commit.commit.author.name,
          nickname: (commit.author.login rescue nil)
        })
      end

      if commit.author && commit.author.login
        user.update nickname: commit.author.login
      end

      # create tip
      tip = tips.create({
        project: self,
        user: user,
        amount: next_tip_amount * modifier,
        commit: commit.sha
      })

      # notify user
      if tip && user.bitcoin_address.blank? && !user.unsubscribed
        if !user.notified_at || (user.notified_at < (Time.now - 30.days))
          UserMailer.new_tip(user, tip).deliver
          user.touch :notified_at
        end
      end

      Rails.logger.info "    Tip created #{tip.inspect}"
    end

  end

  def available_amount
    self.deposits.where("confirmations > 0").map(&:available_amount).sum - tips_paid_amount
  end

  def unconfirmed_amount
    self.deposits.where(:confirmations => 0).map(&:available_amount).sum
  end

  def tips_paid_amount
    self.tips.non_refunded.sum(:amount)
  end

  def tips_paid_unclaimed_amount
    self.tips.non_refunded.unclaimed.sum(:amount)
  end

  def next_tip_amount
    (CONFIG["tip"]*available_amount).ceil
  end

  def self.update_cache
    find_each do |project|
      project.update available_amount_cache: project.available_amount
    end
  end

  def github_info
    client = Octokit::Client.new \
      :client_id     => CONFIG['github']['key'],
      :client_secret => CONFIG['github']['secret']
    if github_id.present?
      client.get("/repositories/#{github_id}")
    else
      client.repo(full_name)
    end
  end

  def github_collaborators
    client = Octokit::Client.new \
      :client_id     => CONFIG['github']['key'],
      :client_secret => CONFIG['github']['secret']
    client.get("/repos/#{full_name}/collaborators")
  end

  def update_info
    begin
      update_github_info(github_info)
      update_github_collaborators(github_collaborators)
    rescue Octokit::BadGateway, Octokit::NotFound, Octokit::InternalServerError,
           Errno::ETIMEDOUT, Net::ReadTimeout, Faraday::Error::ConnectionFailed => e
      Rails.logger.info "Project ##{id}: #{e.class} happened"
    rescue StandardError => e
      Airbrake.notify(e)
    end
  end

  def tips_to_pay
    tips.unpaid.with_address
  end

  def amount_to_pay
    tips_to_pay.sum(:amount)
  end
end
