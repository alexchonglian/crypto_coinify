require 'rpcjson'r
require 'bitcoin/electrum/mnemonic'
require 'money-tree'
class Users::UsercoinsController < ApplicationController
  inherit_resources
  actions :index, :show, :create, :new,  :show, :update, :destroy, :redeem, :auction
  belongs_to :user
  before_action :find_user
  respond_to :html
  def find_user
    @user = User.find(params[:user_id]);
  end

  def index
    self.collection
    puts 'calling>>>>>>>>>>>>>>>>>>>>'
  end


  # Purchasing new Coins action for the user
  def new
    puts "h@@@@@@@@@@@@@@@@@@@@@@@@@@@i"

  end


  # Actually purchasing the coins with update to db and counterpartyd
  def create


  end



  def show
    @params = params
    puts '@@@@@@@@@@@@@@@@@@'
    puts params
  end


  #
  # Redeem specific amount of coins in exchange for certain power at a specific price
  #
  def redeem (amount, power_id, account, opts={})
    authorize resource, :redeem


  end

  def auction
  end


  def collection
    authorize resource
    # Debug
    puts @user.cp_key.split(" ")
    puts "Seed is: " + @user.cp_key
    # Convert the passphrase (in words) to hex (i.e. seed)
    seed = Mnemonic.decode(@user.cp_key.split(" "))
    # Pass in the hex seed key to construct new Master Key (which generates SHA512HMAC)
    master = MoneyTree::Master.new :seed_hex=>seed
    # Get the first child key (which actually stores koins, and used by counterwallet) from the master key
    address = master.node_for_path("m/0'/0/0")
    # Make JSON rpc client connected to the counterpartyd service
    # http://counterpartyd.readthedocs.org/en/latest/API.html
    # client = RPC::JSON::Client.new("http://counterparty:counterparty@localhost:5000")
    client = RPC::JSON::Client.new("http://counterparty:ipYcMLljCmtrDI@54.186.18.161:14000")
    # the URL for the JSON-RPC 2.0 server to connect to
    # Make a get_balance call to query all current asset balance for the user's address (i.e. child key #1)
    result = client.get_balances({field:"address", op:"==",value:address.to_address})
    puts "First address is: " + address.to_address
    puts "Result is: "
    puts result
    @usercoins = result
    # @usercoins ||= end_of_association_chain.without_state('deleted').page(params[:page]).per(10)
  end


end
#
# words = "spill sometimes image cloud floor thrown peel freedom leap also mention accept".split (" ")
# puts words
# seed = Mnemonic.decode(words)
# master = MoneyTree::Master.new :seed_hex=>seed
# address = master.node_for_path("m/0'/0/1")
# puts master.private_key.key
# puts address.to_address