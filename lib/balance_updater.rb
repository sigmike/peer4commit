module BalanceUpdater
  def self.work(projects = Project.all)
    projects.each do |project|
      start = 0
      count = 10

      raise "Project without address label: #{project.inspect}" if project.address_label.blank?

      project.update(account_balance: (BitcoinDaemon.instance.get_balance(project.address_label) * COIN).to_i)

      if project.cold_storage_withdrawal_address.blank?
        new_address = BitcoinDaemon.instance.get_new_address(project.address_label)
        project.update!(cold_storage_withdrawal_address: new_address)
      end

      stake_mint = 0

      loop do
        transactions = BitcoinDaemon.instance.list_transactions(project.address_label, count, start)
        break if transactions.empty?

        transactions.each do |transaction|
          txid = transaction["txid"]
          confirmations = transaction["confirmations"]
          category = transaction["category"]
          fee = transaction["fee"]

          if category == "move"
            next
          end

          if category == "send" and distribution = Distribution.where(txid: txid).first
            raise "No fee on distribution #{distribution.inspect}" unless fee
            distribution.update(fee: -fee * COIN)
            next
          end

          if deposit = project.deposits.find_by_txid(txid)
            deposit.update_attribute(:confirmations, confirmations)
            next
          end

          if cold_storage_transfer = ColdStorageTransfer.find_by_txid(txid)
            cold_storage_transfer.confirmations = confirmations
            cold_storage_transfer.fee = -fee * COIN if fee
            cold_storage_transfer.save!
            next
          end

          address = transaction["address"]
          if address.blank?
            raise "Invalid transaction: #{transaction.inspect}"
          end

          cold_storage_addresses = CONFIG["cold_storage"].try(:[], "addresses") || []
          cold_storage_withdrawal_address = project.cold_storage_withdrawal_address

          amount = (transaction["amount"].to_d * COIN).to_i

          if %w( stake-mint stake ).include?(category)
            # When a block is found, peercoin seems to debit the default account ("") and credit the account associated with the address.
            # So we record these false amounts to remove them in the audit page
            stake_mint += amount
            next
          end

          if category == "stake-orphan"
            next
          end

          if address == cold_storage_withdrawal_address
            if category != "receive"
              raise "Unexpected cold storage withdrawal: #{transaction.inspect}"
            end

            project.cold_storage_transfers.create!(
              address: address,
              txid: txid,
              confirmations: confirmations,
              amount: -amount,
            )
            next
          end

          if cold_storage_addresses.include?(address)
            if category != "send"
              raise "Unexpected cold storage transaction: #{transaction.inspect}"
            end

            project.cold_storage_transfers.create!(
              address: address,
              txid: txid,
              confirmations: confirmations,
              amount: -amount,
              fee: fee,
            )
            next
          end

          if category == "receive"
            if address == project.bitcoin_address
              donation_address = nil
            elsif donation_address = project.donation_addresses.detect { |da| da.donation_address == address}
            else
              raise "Funds received to unexpected address: #{transaction.inspect}"
            end

            deposit = Deposit.create(
              project_id: project.id,
              txid: txid,
              confirmations: confirmations,
              amount: amount,
              duration: 30.days.to_i,
              paid_out: 0,
              paid_out_at: Time.now,
              donation_address: donation_address,
            )
            next
          end

          raise "Unexpected transaction: #{transaction.inspect}"
        end

        project.update(stake_mint_amount: stake_mint)

        break if transactions.size < count
        start += count
      end
    end
  end
end
