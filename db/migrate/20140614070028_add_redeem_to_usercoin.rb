class AddRedeemToUsercoin < ActiveRecord::Migration
  def change
    add_column :usercoins, :redeemed_to, :string
  end
end
