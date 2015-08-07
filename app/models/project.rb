class Project < ActiveRecord::Base
  has_many :deposits # todo: only confirmed deposits that have amount > paid_out
  has_many :tips, inverse_of: :project
  accepts_nested_attributes_for :tips
  has_many :collaborators
  has_many :distributions, inverse_of: :project
  has_many :donation_addresses, inverse_of: :project
  has_many :users, through: :collaborators

  has_many :cold_storage_transfers

  has_one :tipping_policies_text, inverse_of: :project
  accepts_nested_attributes_for :tipping_policies_text

  has_many :commits

  record_changes(except: [:available_amount_cache, :last_commit, :updated_at])

  acts_as_commontable

  validates :name, presence: true

  before_validation :strip_full_name
  after_create :generate_address!

  scope :enabled,  -> { where(disabled: false) }
  scope :disabled, -> { where(disabled: true) }

  def github_url
    "https://github.com/#{full_name}" if full_name.present?
  end

  def source_github_url
    "https://github.com/#{source_full_name}"
  end

  def get_commits
    begin
      commits = Timeout::timeout(90) do
        client = Octokit::Client.new \
          :client_id     => CONFIG['github']['key'],
          :client_secret => CONFIG['github']['secret'],
          :per_page      => 100
        client.commits(full_name)
      end
    rescue Octokit::BadGateway, Octokit::NotFound, Octokit::InternalServerError,
           Errno::ETIMEDOUT, Faraday::Error::ConnectionFailed, Octokit::Forbidden,
           Octokit::Conflict => e
      Rails.logger.info "Project ##{id}: #{e.class} happened"
    rescue StandardError => e
      if CONFIG["airbrake"]
        Airbrake.notify(e)
      else
        raise
      end
    end
    sleep(1)
    commits || []
  end

  def update_commits
    commits = get_commits

    commits.each do |commit|
      Commit.where(
        project: self,
        sha: commit.sha,
      ).first_or_create!(
        message: commit.commit.message,
        username: commit.author.try(:login),
        email: commit.commit.author.email,
      )
    end
  end

  def tip_commits
    return unless self.deposits.any?
    return if available_amount == 0

    commits = get_commits

    commits.each do |commit|
      next if Tip.where(project_id: id, commit: commit.sha).any?

      # Filter merge request
      next if commit.commit.message =~ /^(Merge\s|auto\smerge)/
      # Filter fake emails
      next unless commit.commit.author.email =~ Devise::email_regexp
      # Filter committed after t4c project creation
      next unless commit.commit.committer.date > self.deposits.first.created_at

      Project.transaction do
        tip_for commit
        update_attribute :last_commit, commit.sha
      end
    end
  end

  def tip_for commit
    email = commit.commit.author.email
    if nickname = commit.author.try(:login)
      user = User.enabled.find_by(nickname: nickname)
    end
    user ||= User.enabled.find_by(email: email)

    if (next_tip_amount > 0) and
        Tip.find_by(commit: commit.sha).nil? and
        user

      if hold_tips
        amount = nil
      else
        amount = next_tip_amount
      end

      # create tip
      tip = tips.create!({
        user: user,
        amount: amount,
        commit: commit.sha,
        commit_message: ActionController::Base.helpers.truncate(commit.commit.message, length: 100),
      })

      tip.notify_user

      Rails.logger.info "    Tip created #{tip.inspect}"
    end

  end
  
  def total_deposited
    self.deposits.where("confirmations > 0").map(&:available_amount).sum
  end

  def available_amount
    total_deposited - tips_paid_amount
  end

  def unconfirmed_amount
    self.deposits.where(:confirmations => 0).map(&:available_amount).sum
  end

  def tips_paid_amount
    self.tips.select(&:decided?).reject(&:refunded?).sum(&:amount)
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

  def tips_to_pay
    tips.select(&:to_pay?)
  end

  def amount_to_pay
    tips_to_pay.sum(&:amount)
  end

  def has_undecided_tips?
    tips.undecided.any?
  end

  def commit_url(commit)
    "https://github.com/#{full_name}/commit/#{commit}"
  end

  def cold_storage_amount
    cold_storage_transfers.to_a.select(&:confirmed?).sum(&:amount)
  end

  def send_to_cold_storage!(amount, address_index = 0)
    address = CONFIG["cold_storage"].try(:[], "addresses").try(:[], address_index)
    raise "No cold storage address" if address.blank?
    BitcoinDaemon.instance.send_many(address_label, {address => amount.to_f})
  end

  def paid_fee
    [
      distributions.map(&:fee),
      cold_storage_transfers.map(&:fee),
    ].flatten.compact.sum
  end

  def strip_full_name
    if full_name_changed? and full_name.present?
      self.full_name = full_name.gsub(/https?\:\/\/github.com\//, '')
    end
  end

  def github?
    full_name.present?
  end

  def auto_tip_commits
    !hold_tips
  end
  alias_method :auto_tip_commits?, :auto_tip_commits

  def auto_tip_commits=(value)
    self.hold_tips = case value
                     when false, nil, "0" then true
                     else false
                     end
  end

  def generate_address!
    return if bitcoin_address.present? or address_label.present?
    self.address_label = "peer4commit-#{id}"
    self.bitcoin_address = BitcoinDaemon.instance.get_new_address(address_label)
    save(validate: false)
  end

  def to_label
    name.presence || id.to_s
  end
end
