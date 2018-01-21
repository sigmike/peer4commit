class AddStakeMintToProject < ActiveRecord::Migration
  def change
    add_column :projects, :stake_mint_amount, :integer, limit: 8
  end
end
