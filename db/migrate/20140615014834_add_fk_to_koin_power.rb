class AddFkToKoinPower < ActiveRecord::Migration
  def change
    add_column :koin_powers, :coin_id, :integer
  end
end
