class Usercoin < ActiveRecord::Base
  # attr_accessible :user_id, :coin_id, :amount, :redeemed_to
  validates_presence_of :user_id, :coin_id
  belongs_to :coin
  belongs_to :user

  has_many :redeem_records
  delegate :display_image, to: :coin

  ## Features contain of {feature, requirement}
  serialize :redeemed_to, JSON

  ## Instead of replicating coin name and description in this table,
  ## we'll be establishing a belongs_to relationship and
  ## create  shortcut method to allow access to coin's name and description

  # Shortcut to coin name retrieved from coin table
  def name
    coin.name
  end

  def self.sum_by_coin
    scoped.group(:user_id, :coin_id).sum(:amount)
  end

  # Shortcut to coin name retrieved from coin table

  def description
    coin.description
  end

  def redeem(amount, power_id, account, opts={})
    self.amount -= amount
    self.redeemed_amount += amount
    qty = amount / KoinPower.find(power_id).cost
    r = RedeemRecord.new(usercoin_id: self.id, amount: amount, koin_power_id: power_id, power_quantity: qty, account: account, options:opts)
    puts r.errors.messages
    puts r.valid?
    r.save
  end
end
