class AddAmountToKoinRewardsFulfill < ActiveRecord::Migration
  def change
    add_column :koin_rewards_fulfills, :amount, :integer
  end
end
