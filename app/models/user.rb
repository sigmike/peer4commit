class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:github]
  devise :confirmable, reconfirmable: true

  validates :bitcoin_address, bitcoin_address: true
  validates :password, confirmation: true

  has_many :tips

  has_many :collaborators
  has_many :projects, through: :collaborators

  has_many :tipping_policies_texts
  has_many :record_changes

  before_create :generate_login_token!, unless: :login_token?
  before_create :assign_random_identifier, unless: :identifier?

  acts_as_commontator
  acts_as_commontable

  scope :enabled,  -> { where(disabled: false) }
  scope :disabled, -> { where(disabled: true) }

  def github_url
    "https://github.com/#{nickname}"
  end

  def balance
    tips.unpaid.sum(:amount)
  end

  def full_name
    name.presence || nickname.presence || email
  end

  def self.update_cache
    commits_counts = Tip.group(:user_id).count
    paid_sums = Tip.paid.group(:user_id).sum(:amount)

    find_each do |user|
      user.commits_count = commits_counts[user.id] || 0
      user.withdrawn_amount = paid_sums[user.id] || 0
      user.save
    end
  end

  def has_password?
    encrypted_password_was.present?
  end

  def password_required?
    false
  end

  def email_required?
    false
  end

  def recipient_label
    if nickname.present?
      nickname
    elsif email.present?
      if new_record?
        "#{email} (new user)"
      else
        email
      end
    elsif identifier.present?
      identifier
    else
      "Unknown user"
    end
  end

  def valid_github_user?
    return false unless nickname.present?

    client = Octokit::Client.new(client_id: CONFIG['github']['key'], client_secret: CONFIG['github']['secret'])
    begin
      client.user(nickname)
      true
    rescue Octokit::NotFound
      false
    end
  end

  def reset_confirmation_token!
    generate_confirmation_token!
  end

  def merge_into!(other)
    raise unless id
    raise unless other.id

    self.class.transaction do
      logger.info "Merging #{inspect} into user #{other.inspect}"
      [
        :collaborators,
        :tipping_policies_texts,
        :record_changes,
        :tips,
      ].each do |association|
        send(association).each do |record|
          logger.info "Updating user id from #{record.user_id} to #{other.id} on #{record.inspect}"
          record.update_columns(user_id: other.id)
        end
      end
      update_attribute(:disabled, true)
    end
  end

  def active_for_authentication?
    super and !disabled?
  end

  private

  def generate_login_token!
    loop do
      self.login_token = SecureRandom.urlsafe_base64
      break unless User.exists?(login_token: login_token)
    end
  end

  def assign_random_identifier
    charset = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'.split(//)
    loop do
      self.identifier = (0...12).map { charset.sample }.join
      break unless User.exists?(identifier: identifier)
    end
  end

end
