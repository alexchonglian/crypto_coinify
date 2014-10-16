class CreateRedeemRecord < ActiveRecord::Migration
  def change
    create_table :redeem_records do |t|
      t.string :amount
      t.float :power_quantity
      t.timestamp :date
    end
  end
end
