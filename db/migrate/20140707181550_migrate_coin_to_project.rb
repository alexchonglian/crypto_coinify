class MigrateCoinToProject < ActiveRecord::Migration
  def up
    add_column :projects, :koin_powers_and_features, :json
    add_column :projects, :total_amount, :decimal
    add_column :projects, :total_issued, :decimal
    add_column :projects, :amount_mined, :decimal
    add_column :projects, :sold, :decimal
    add_column :projects, :redeemed, :decimal
    add_column :projects, :price, :decimal
  end

  def down
    remove_column :projects, :koin_powers_and_features
    remove_column :projects, :total_amount
    remove_column :projects, :total_issued
    remove_column :projects, :amount_mined
    remove_column :projects, :sold
    remove_column :projects, :redeemed
    remove_column :projects, :price
  end
end
