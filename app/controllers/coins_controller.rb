# coding: utf-8
require 'active_support/core_ext'
require 'counterparty'
class CoinsController < ApplicationController
  before_filter :set_headers

  inherit_resources

  respond_to :html


  def find
    coin_id = params[:id]
    puts params
    c = Coin.find(coin_id)
    p = KoinPower.find_all_by_coin_id(c.id)
    f = KoinFeature.find_all_by_coin_id(c.id)
    
    user_id = params[:user_id]

    uc = Usercoin.where(coin_id:coin_id, user_id:user_id)
    h = {coin: c, powers:p, features:f,usercoin: uc}
    render json: h

  end


  def redeem

    coin_id = params[:id]
    user_id = current_user.id
    amount = params[:amount]
    account = params[:account]
    power_id = params[:power_id]
    puts params
    uc = Usercoin.where(coin_id:coin_id, user_id:user_id)
    if (uc == nil)
      raise Exception("No coin available to this user")
    end
    uc = uc.first
    uc.redeem(amount, power_id, account)

  end

  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Expose-Headers'] = 'ETag'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match'
    headers['Access-Control-Max-Age'] = '86400'
  end

end
