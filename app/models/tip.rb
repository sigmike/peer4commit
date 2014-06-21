class Tip < ActiveRecord::Base
  belongs_to :user
  belongs_to :distribution, touch: true
  belongs_to :project, inverse_of: :tips
  belongs_to :reason, polymorphic: true

  validates :amount, numericality: {greater_or_equal_than: 0, allow_nil: true}
  validate :validate_reason

  scope :not_sent,      -> { where(distribution_id: nil) }
  def not_sent?
    distribution_id.nil?
  end

  scope :unpaid,        -> { non_refunded.not_sent }
  def unpaid?
    non_refunded? and not_sent?
  end

  scope :to_pay,        -> { unpaid.decided.not_free.with_address }
  def to_pay?
    unpaid? and decided? and !free? and with_address?
  end

  scope :free,          -> { where('amount = 0') }
  scope :not_free,      -> { where('amount > 0') }
  def free?
    amount == 0
  end

  scope :paid,          -> { where.not(distribution_id: nil) }
  def paid?
    !!distribution_id
  end

  scope :refunded,      -> { where.not(refunded_at: nil) }
  scope :non_refunded,  -> { where(refunded_at: nil) }
  def refunded?
    !!refunded_at
  end
  def non_refunded?
    !refunded?
  end

  scope :unclaimed,     -> { joins(:user).
                             unpaid.
                             where('users.bitcoin_address' => ['', nil]) }

  scope :with_address,  -> { joins(:user).where.not('users.bitcoin_address' => [nil, ""]) }
  def with_address?
    user.bitcoin_address.present?
  end

  scope :decided,       -> { where.not(amount: nil) }
  scope :undecided,     -> { where(amount: nil) }
  def decided?
    !!amount
  end
  def undecided?
    !decided?
  end
  def was_undecided?
    amount_was.nil?
  end


  after_save :notify_user_if_just_decided
  before_save :touch_decided_at_if_decided


  def self.refund_unclaimed
    unclaimed.non_refunded.
    where.not(decided_at: nil).
    where('tips.decided_at < ?', Time.now - 1.month).
    find_each do |tip|
      tip.touch :refunded_at
    end
  end

  def commit_url
    project.commit_url(commit)
  end

  attr_accessor :decided_amount_percentage
  attr_accessor :decided_free_amount

  def notify_user
    if amount and amount > 0 and user.bitcoin_address.blank? and !user.unsubscribed
      if user.notified_at.nil? or user.notified_at < 30.days.ago
        UserMailer.new_tip(user, self).deliver
        user.touch :notified_at
      end
    end
  end

  def notify_user_if_just_decided
    return if distribution_id
    notify_user if amount_was.nil? and amount
  end

  def touch_decided_at_if_decided
    self.decided_at = Time.now if amount_changed? && decided?
  end

  def coin_amount
    amount.to_f / COIN if amount
  end

  def coin_amount=(coin_amount)
    if coin_amount.present?
      self.amount = (coin_amount.to_f * COIN).round
    else
      self.amount = nil
    end
  end

  def self.build_from_commit(commit)
    if commit.username.present?
      user = User.where(nickname: commit.username).first_or_initialize(email: commit.email)
    elsif commit.email =~ Devise::email_regexp
      user = User.where(email: commit.email).first_or_initialize
    else
      return nil
    end
    if user.new_record?
      raise "Invalid email address" unless user.email =~ Devise::email_regexp
      user.skip_confirmation_notification!
      user.save!
    end
    new(user_id: user.id, reason: commit)
  end

  def validate_reason
    case reason_type
    when nil, ""
      errors.add(:reason_id, :present) unless reason_id.blank?
    when "Commit"
      errors.add(:reason_id, :invalid) unless project.commits.include?(reason)
    else
      errors.add(:reason_type, :invalid)
    end
  end
end
