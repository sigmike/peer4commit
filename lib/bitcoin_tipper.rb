class BitcoinTipper
  def self.work_forever
    while true do
      self.work
    end
  end

  def self.work
    Rails.logger.info "Traversing projects..."
    Project.find_each do |project|
      if project.available_amount > 0
        Rails.logger.info " Project #{project.id} #{project.full_name}"
        project.tip_commits
      end
    end

    Rails.logger.info "Updating projects info..."
    Project.order(:updated_at => :desc).last(10).each do |project|
      Rails.logger.info " Project #{project.id} #{project.full_name}"
      project.update_info
    end

    self.create_sendmany

    Rails.logger.info "Traversing sendmanies..."
    Sendmany.where(txid: nil).each do |sendmany|
      sendmany.send_transaction
    end

    Rails.logger.info "Refunding unclaimed tips..."
    Tip.refund_unclaimed

    Rails.logger.info "Updating projects cache..."
    Project.update_cache

    Rails.logger.info "Updating users cache..."
    User.update_cache
  end

  def self.create_sendmany
    Rails.logger.info "Creating sendmany"
    ActiveRecord::Base.transaction do
      Project.find_each do |project|
        tips = project.tips.unpaid.with_address.readonly(false)
        amount = tips.sum(:amount).to_d / PeercoinBalanceUpdater::COIN
        if amount > CONFIG["min_payout"]
          sendmany = Sendmany.create(project_id: project.id)
          outs = {}
          tips.each do |tip|
            tip.update_attribute :sendmany_id, sendmany.id
            outs[tip.user.bitcoin_address] = outs[tip.user.bitcoin_address].to_i + tip.amount.to_d / PeercoinBalanceUpdater::COIN
          end
          sendmany.update_attribute :data, outs.to_json
          Rails.logger.info "  #{sendmany.inspect}"
        end
      end
    end   
  end

end
