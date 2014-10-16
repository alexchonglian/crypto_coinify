class AddCoinidToRewardsfulfill < ActiveRecord::Migration
  def change
    add_column :koin_rewards_fulfills, :coin_id, :integer
  end
end
