class RenameBitcoinAddressToPeercoinAddressInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :bitcoin_address, :peercoin_address
  end
end
