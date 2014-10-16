class AddKoinpowerToCoins < ActiveRecord::Migration
  def change
    add_column :coins, :koinpower, :string
  end
end
