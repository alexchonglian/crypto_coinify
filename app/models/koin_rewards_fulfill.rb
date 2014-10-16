class KoinRewardsFulfill < ActiveRecord::Base
  belongs_to :koin_reward
  belongs_to :user


  delegate :coin_id, to: :koin_reward
end
