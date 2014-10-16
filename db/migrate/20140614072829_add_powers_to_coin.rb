class AddPowersToCoin < ActiveRecord::Migration
  def change
    add_column :coins, :powers, :string
  end
end
