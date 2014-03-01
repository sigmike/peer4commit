class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:github]

  validates :bitcoin_address, :bitcoin_address => true

  has_many :tips

  def github_url
    "https://github.com/#{nickname}"
  end

  def balance
  	tips.unpaid.sum(:amount)
  end

  def subscribed?
    !unsubscribed?
  end

  after_create :generate_login_token!
  def generate_login_token!
    if login_token.blank?
      self.update login_token: SecureRandom.urlsafe_base64
    end
  end

  def full_name
    if !name.blank?
      name
    elsif !nickname.blank?
      nickname
    else
      email
    end
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


  def self.find_or_create_with_commit commit
    author = commit.commit.author
    where(email: author.email).first_or_create do |user|
      user.email    = author.email
      user.password = Devise.friendly_token.first(Devise.password_length.min)
      user.name     = author.name
      user.nickname = commit.author.try(:login)
    end
  end

end
