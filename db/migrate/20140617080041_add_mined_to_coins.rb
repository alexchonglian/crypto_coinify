class AddMinedToCoins < ActiveRecord::Migration
  def change
    add_column :coins, :amount_mined, :integer
  end
end
