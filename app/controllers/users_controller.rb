# coding: utf-8
require 'rpcjson'
require 'bitcoin/electrum/mnemonic'
require 'money-tree'

class UsersController < ApplicationController
  after_filter :verify_authorized, except: %i[uservoice_gadget]
  skip_before_filter :force_http, only: [:update_password]
  inherit_resources
  defaults finder: :find_active!
  actions :show, :update, :update_password, :unsubscribe_notifications, :uservoice_gadget, :credits
  respond_to :json, only: [:contributions, :projects]

  # def get_coin_info
  #     user_id = current_user.id
  #     res = Usercoin.find_by(user_id: user_id)
  #     puts res
  #     render json: res
  # end

  def unsubscribe_notifications
    authorize resource
    redirect_to user_path(current_user, anchor: 'unsubscribes')
  end

  def credits
    authorize resource
    redirect_to user_path(current_user, anchor: 'credits')
  end

  def uservoice_gadget
    if params[:secret] == CatarseSettings[:uservoice_secret_gadget]
      @user = User.find_by_email params[:email]
    end

    render :uservoice_gadget, layout: false
  end

  def show
    authorize resource
    retrieve_usercoins
    show!{
      fb_admins_add(@user.facebook_id) if @user.facebook_id
      @title = "#{@user.display_name}"
      @credits = @user.contributions.can_refund
      @subscribed_to_updates = @user.updates_subscription
      @unsubscribes = @user.project_unsubscribes
    }
  end

  def retrieve_usercoins
    uid, uname = params[:id].split('-') # e.g. 3-alexchonglian
    @coin_lists = Usercoin.select(:coin_id, :user_id, "sum(amount) as amount", "sum(redeemed_amount) as redeemed_amount").where(user_id: uid).group(:coin_id, :user_id).order("amount")
    @coin_lists = @coin_lists.collect {|c| {name: c.coin.name, description: c.coin.description, amount: c.amount, redeemed_amount: c.redeemed_amount}}
    puts "Here's the user coin list: "
    puts @coin_lists

    # @coin_lists = hiscoins.map {|coin| [coin.name, coin.amount.to_i, coin.redeemed_amount.to_i, coin.description, coin.updated_at]}
    #'debugging info: from UserController.show()'
  end

  def update
    authorize resource
    update! do |success,failure|
      success.html do
        flash[:notice] = t('users.current_user_fields.updated')
      end
      failure.html do
        flash[:error] = @user.errors.full_messages.to_sentence
      end
    end
    return redirect_to user_path(@user, anchor: 'settings')
  end

  def update_password
    authorize resource
    if @user.update_with_password(params[:user])
      flash[:notice] = t('users.current_user_fields.updated')
    else
      flash[:error] = @user.errors.full_messages.to_sentence
    end
    return redirect_to user_path(@user, anchor: 'settings')
  end

  def account_detail
    layout 'catarse_bootstrap'
    render :action => 'index'
  end




end