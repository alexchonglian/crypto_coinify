
# This is an API service exposed to external app and game developer
# to inquiry koin redemption for specified account.

require 'counterparty'

class Api::KoinController < ActionController::Base
  include Concerns::ExceptionHandler

  before_filter :set_headers


  def get_coin_info
    respond_to do |format|
      format.json {
        user_id = current_user.id
        res = Usercoin.joins(:coin).where(user_id: user_id).select("usercoins.id, coins.name, usercoins.coin_id, usercoins.amount")
        puts res
        render :json => {res:"ok", data:res}
      }
    end
  end

  def fulfill_rewards(user_id, twitter = nil)
    if (user_id != nil)
      pending = KoinRewardsFulfill.where(user_id: user_id, trigger_status: 1, fulfill_status: "0")
    elsif (twitter != nil)
      pending = KoinRewardsFulfill.where(twitter_handle: twitter, trigger_status: 1, fulfill_status: "0")
    else
      raise Exception("Must provide a user id OR twitter handle")
    end
    pending.each do |r|
      puts r
      reward = r.koin_reward
      puts reward
      if (user_id != nil)
        uc = Usercoin.new(user_id: user_id, coin_id:r.coin_id, amount: reward.amount)
      else
        u = User.where(twitter: twitter).first
        uc = Usercoin.new(user_id: u.id, coin_id:r.coin_id, amount: reward.amount)
      end

      puts "Errors: " + uc.errors.messages.to_s
      if (uc.save)
        uc.coin.amount_mined = (uc.coin.amount_mined) ? (reward.amount+uc.coin.amount_mined) : reward.amount
        uc.coin.save
        r.fulfill_status = "1"
        puts "RewardFulfill errors" + r.errors.messages.to_s
        r.save
      end


      mycoin = uc.coin
      myuser = uc.user
      # Synchronize to counterparty and create a new asset
      #
      # cp = Counterparty.new
      # cp.give_coin(@mycoin.name, @myuser.cp_address, reward.amount)


    end

  end

  def addToRewardQueue(koin_reward_id, user_id, twitter)
    if (user_id != nil)
      f = KoinRewardsFulfill.new(koin_reward_id: koin_reward_id, user_id: user_id,  trigger_status: 1, fulfill_status: "0")
    else
      f = KoinRewardsFulfill.new(koin_reward_id: koin_reward_id, twitter_handle: twitter,  trigger_status: 1,  fulfill_status: "0")
    end

    f.save
    f
  end

  def redeem_for_item(account, user_id, _Koin_power_id)
    koin_power = KoinPower.find(_Koin_power_id)
    coin_id = koin_power.coin_id
    puts "redeeming: user_id: %s, Koin_power_id: %s, coin_id"  % [user_id, _Koin_power_id, coin_id]
    user_coin = Usercoin.find_by(coin_id: coin_id, user_id: user_id)
    diff = user_coin.amount - koin_power.cost
    if (diff < 0)
      #raise Exception("Not enough amount for this user's coin to redeem the power")
      return false
    else
      last_redeemed_amount = user_coin.redeemed_amount
      user_coin.update(amount: diff, redeemed_amount: last_redeemed_amount+koin_power.cost)

      RedeemRecord.create(amount:koin_power.cost,
                          usercoin_id: user_coin.id,
                          koin_power_id: koin_power.id,
                          power_quantity: 1,
                          date: Time.now,
                          account: account
      )
      puts "power redeemed"
      return true
    end
  end

  def redeem
    respond_to do |format|
      format.json {
        error = 0
        coin_power_ids = params[:coin_power_ids ]
        account = params[:account ]
        resp = {}
        user_id = current_user.id
        coin_power_ids.each{
          |x|
          if (!redeem_for_item(account, user_id, x))
            error = 1
          end
        }
        resp['error'] = error
        puts resp
        render :json => resp
      }
    end
  end


  def redeem_record
    respond_to do |format|
      format.json{
        coin_name = params[:coin_name]
        account = params[:account]

        records = RedeemRecord.joins(:usercoin => :coin).joins(:koin_power).where('coins.name'=>coin_name, account:account).select("koin_powers.id, koin_powers.name, redeem_records.amount, redeem_records.power_quantity")
#        .sum("redeem_records.amount")

        ret = {}

        amount = 0
        power_quantity = 0
        records.each do |r|
          if !ret.has_key?(r.name)
            ret[r.name] = {"amount"=>0, "power_quantity"=>0}
          end
          ret[r.name]["amount"] += r.amount.to_f
          ret[r.name]["power_quantity"] += r.power_quantity
        end
        render :json => ret
      }
    end
  end

  def reward
    respond_to do |format|
      format.json {
        poster = params[:poster]
        retweeter = params[:retweeter]
        koin_name = params[:koin]
        if (poster == nil or koin_name == nil)
          puts "Missing parameters!!" + params.to_s
          render :json => {status: "Failure: missing params"}
          return

        end
        ## Look for the reward based on these params
        poster = User.where(twitter: poster).first
        puts poster
        # retweeter = User.where(twitter: retweeter).first
        koin = Coin.find_all_by_name(koin_name).first

        if (koin == nil)
          puts " Koin not found: " +  koin_name.to_s
          render :json => {status: " Koin not found: " + poster.to_s + "/"  + koin.to_s}
          return
        end

        # timestamp = params[:timestamp]
        puts params

        rewards = KoinReward.where(coin_id: koin.id, trigger: "twitter" )

        if (rewards == nil)
          puts "No corresponding rewards found"
          render :json => {msg: "No corresponding rewards found"}

          return

        end
        rewards.each do |reward|
          puts reward
          if (poster == nil)
            f = addToRewardQueue(reward.id, nil, poster)
          else
            f = addToRewardQueue(reward.id, poster.id, poster)
          end

          if (retweeter != nil)
            f = addToRewardQueue(reward.id, nil, retweeter)
          end

          if (poster != nil)
            self.fulfill_rewards(poster.id)
          end


        end


        resp = {msg: "Rewarded! "}
        puts resp
        render :json => resp
      }
    end
  end


  def index
    respond_to do |format|
      format.json {
        account = params[:account]
        koin = params[:koin]
        c = Coin.find_all_by_name(koin).first

        sql = "select redeemed_to from usercoins where coin_id=#{c.id} and redeemed_to->>'account'='#{account}'"
        puts sql
        usercoin = Usercoin.find_by_sql(sql)
        puts "Redeemed to: " + usercoin.to_s


        redeemed = usercoin
        # powers = [{
        #               :name=>"More Mushroom",
        #               :id=>1
        #           },
        #           {
        #               :name=>"Skip level",
        #               :id=>2
        #           }
        # ]

        resp = {account: account, powers: redeemed}
        puts resp
        render :json => resp
      }
    end
  end


  private


  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Expose-Headers'] = 'ETag'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match'
    headers['Access-Control-Max-Age'] = '86400'
  end

end
