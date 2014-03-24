class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:github]

# Validations
  validates :bitcoin_address, :bitcoin_address => true

# Associations
  has_many :tips
  
  # Callbacks
   before_create :set_login_token!, unless: :login_token?
 
  # Instance Methods
  def github_url
    "https://github.com/#{nickname}"
  end

  def balance
  	tips.unpaid.sum(:amount)
    
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
  
# Class Methods
  def self.update_cache
    commits_counts = Tip.group(:user_id).count
    paid_sums = Tip.paid.group(:user_id).sum(:amount)

    find_each do |user|
      user.commits_count = commits_counts[user.id] || 0
      user.withdrawn_amount = paid_sums[user.id] || 0
      user.save
    end
  end

private
 
   def set_login_token!
     loop do
       self.login_token = SecureRandom.urlsafe_base64
       break login_token unless User.exists?(login_token: login_token)
     end
   end
end
