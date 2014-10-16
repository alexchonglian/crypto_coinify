class ChangeRedeemedToJson < ActiveRecord::Migration
  def change
    remove_column :usercoins, :redeemed_to

  end
end
