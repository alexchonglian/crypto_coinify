class CreateKoinRewardsFulfill < ActiveRecord::Migration
  def change
    create_table :koin_rewards_fulfills do |t|
      t.integer :koin_reward_id
      t.integer :user_id

      ## Potential new users who might use any of these social media network to sign up
      t.text :twitter_handle
      t.text :facebook_handle
      t.text :linkedin_handle

      t.integer :trigger_status
      t.string :fulfill_status
      t.date :fulfill_date
    end
  end
end
