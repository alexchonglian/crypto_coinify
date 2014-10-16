class AddCoinStatusToContribution < ActiveRecord::Migration
  def change
    add_column :contributions, :coin_status, :string
  end
end
