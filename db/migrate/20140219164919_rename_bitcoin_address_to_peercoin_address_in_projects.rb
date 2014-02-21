class RenameBitcoinAddressToPeercoinAddressInProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :bitcoin_address, :peercoin_address
  end
end
