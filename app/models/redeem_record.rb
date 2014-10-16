class RedeemRecord < ActiveRecord::Base
  validates_presence_of :amount, :power_quantity
  belongs_to :usercoin
  belongs_to :koin_power
  delegate :coin, :to => :koin_power

  store :options, coder: JSON

end