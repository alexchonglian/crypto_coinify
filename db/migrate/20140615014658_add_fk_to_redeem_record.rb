class AddFkToRedeemRecord < ActiveRecord::Migration
  def change
    add_column :redeem_records, :usercoin_id, :integer
    add_column :redeem_records, :koin_power_id, :integer
  end
end
