class Tip < ActiveRecord::Base
  belongs_to :user
  belongs_to :sendmany
  belongs_to :project

  validates :amount, :numericality => { :greater_than => 0 }

  scope :unpaid,        -> { non_refunded.
                             where(sendmany_id: nil) }

  scope :paid,          -> { where('sendmany_id is not ?', nil) }

  scope :refunded,      -> { where('refunded_at is not ?', nil) }

  scope :non_refunded,  -> { where(refunded_at: nil) }

  scope :unclaimed,     -> { joins(:user).
                             unpaid.
                             where('users.bitcoin_address' => ['', nil]) }

  scope :with_address,  -> { joins(:user).where('users.bitcoin_address IS NOT NULL AND users.bitcoin_address != ?', "") }

  def paid?
    !!sendmany_id
  end

  def self.refund_unclaimed
    unclaimed.non_refunded.
    where('tips.created_at < ?', Time.current - 1.month).
    find_each do |tip|
      tip.touch :refunded_at
    end
  end
end
