class AddAccountToRedeemRecord < ActiveRecord::Migration
  def change
    add_column :redeem_records, :account, :string
    add_column :redeem_records, :options, :string
  end
end
