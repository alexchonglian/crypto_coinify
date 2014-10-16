class AddRedeemedToUsercoin < ActiveRecord::Migration
  def change
    add_column :usercoins, :redeemed_to, :json
  end
end
