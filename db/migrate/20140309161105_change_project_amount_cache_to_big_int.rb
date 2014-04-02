class ChangeProjectAmountCacheToBigInt < ActiveRecord::Migration
  def change
    change_column :projects, :available_amount_cache, :integer, limit: 8
  end
end
