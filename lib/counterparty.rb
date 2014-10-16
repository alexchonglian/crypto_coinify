#!/usr/local/bin/ruby
require_relative 'koin_rpcjson'
require 'bitcoin/electrum/mnemonic'
require 'money-tree'
class Counterparty
  $CP_TESTNET_CONFIG =
      {source: "moXbGoNzKSPPTCrNkETihSijdKrcUKWXiN",
       url: "http://rpc:ipYcMLljCmtrDI@54.186.18.161:14000"
      }
  $CP_TESTNET_CONFIG_VONJON =
      {source: "n2pZKpTdt2cuuibnCyKtuK1f8yNRjYvQnm",
       url: "http://rpc:ipYcMLljCmtrDI@54.186.18.161:14000"
      }
  $CP_TESTNET_CONFIG_2 =
      {source: "n3u2zXCj3SUCTAwG8gx2skqb6muBRjcb7W",
       url: "http://counterparty:ipYcMLljCmtrDI@54.186.18.161:14000"
      }
  $CP_CONFIG = $CP_TESTNET_CONFIG_VONJON
  $BTC_TESTNET_CONFIG =
      {
       url: "http://rpc:IGso1hllKl6TLG@54.186.18.161:18332"
      }
  $BTC_CONFIG = $BTC_TESTNET_CONFIG

  #$priv_key = "cTHEhQ7tLpKRVFBgsTmZTyZzRbUHXGLgWARusU2H8jqSNDDWGZ2S"
  $priv_key = "cMmLE5WbucejLZgfzQHM6PqEtR4H1qD3tafFmBibqqGsf2CZMxnU"


  def import_privkey
    puts $BTC_CONFIGn
    client = RPC::JSON::Client.new($BTC_CONFIG[:url])
    client.importprivkey($priv_key)

  end

  def give_coin(name, receiver, quantity)
    client = RPC::JSON::Client.new($CP_CONFIG[:url])

    txn_msg = client.create_send($CP_CONFIG[:source], receiver, name, quantity)
    txn_msg = client.sign_tx(txn_msg)
    puts txn_msg
    client.broadcast_tx(txn_msg)
  end

  def passphrase_to_address(pass, testnet=true)
    seed = Mnemonic.decode(pass.split(" "))

    # Pass in the hex seed key to construct new Master Key (which generates SHA512HMAC)
    if (testnet)
      master = MoneyTree::Master.new ({:seed_hex=>seed, :network=>:bitcoin_testnet})
    else
      master = MoneyTree::Master.new ({:seed_hex=>seed, :network=>:bitcoin})
    end

    # Get the first child key (which actually stores koins, and used by counterwallet) from the master key
    address = master.node_for_path("m/0'/0/0")
    return address.to_address

  end

  def move_coin(sender, receiver, name, quantity)
    client = RPC::JSON::Client.new($CP_CONFIG[:url])

    txn_msg = client.create_send($CP_CONFIG[:source], receiver, name, quantity)
    txn_msg = client.sign_tx(txn_msg)
    puts txn_msg
    resp = client.broadcast_tx(txn_msg)
    puts resp
  end



  def create_asset(name, description, quantity, divisible=false, callable=false, call_price=nil, call_date=nil, transfer_destination=nil, lock=false)
    puts $CP_CONFIG
    if asset_balance(name) > 0
      puts "Already exist asset #{name}. Give up."
      raise Exception.new("Asset already exists in counterparty: #{name}")
    end
    client = RPC::JSON::Client.new($CP_CONFIG[:url])

    # result = client.get_balances({field:"address", op:"==",value:"moXbGoNzKSPPTCrNkETihSijdKrcUKWXiN"})
    # puts result

    txn_msg = client.create_issuance($CP_CONFIG[:source], name, quantity, divisible, description)
    if (txn_msg["code"] != nil)
      puts "Error: " + txn_msg["code]"]
      raise Exception.new("Counterparty error: #{txn_msg['code']}")
    end



    puts "Creating asset: " + name
    # client = RPC::JSON::Client.new($BTC_CONFIG[:url])
    txn_msg = client.sign_tx(txn_msg)
    client.broadcast_tx(txn_msg)

    t = Thread.new {
      sleep(10*60)
      # Call asset creation again, in case it's not created succcessfully
      create_asset(name, description,  quantity, divisible, callable, call_price, call_date, transfer_destination, lock)
    }
    puts Thread.current

    puts " Joining thread"

    puts Thread.current


    puts "Thread joined. REturning"
    true
  end

#Jie
  def get_asset_info(assets)
    client = RPC::JSON::Client.new($CP_CONFIG[:url])
    #result = client.get_balances({field:"address", op:"==",value:"moXbGoNzKSPPTCrNkETihSijdKrcUKWXiN"})
    result = client.get_asset_info(assets)
    return result
  end

  def asset_balance(name)
    client = RPC::JSON::Client.new($CP_CONFIG[:url])
    result = client.get_balances({field:"address", op:"==",value:$CP_CONFIG[:source]})
    bal = 0
    # puts result
    for a in result
      # puts a["asset"]
      if a["asset"]==name
        bal += a["quantity"]
      end
    end
    bal
  end

  def create_burn(quantity)
    client = RPC::JSON::Client.new($CP_CONFIG[:url])
    return client.create_burn($CP_CONFIG[:source], quantity)
  end
  def create_send(destination, asset, quantity)
    client = RPC::JSON::Client.new($CP_CONFIG[:url])
    return client.create_send($CP_CONFIG[:source], destination, asset, quantity )
  end
  def create_order(give_asset, give_quantity, get_asset, get_quantity, fee_provided=20000, expiration=1000)
    client = RPC::JSON::Client.new($CP_CONFIG[:url])
    return client.create_order($CP_CONFIG[:source], give_asset, give_quantity,
                               get_asset, get_quantity, expiration, 0, fee_provided)
  end

  def pad(field, op, value)
    return {"field" => field, "op" => op, "value" => value}
  end
  def get_orders_by_addrs(addrs)
    client = RPC::JSON::Client.new($CP_CONFIG[:url])
    elems = []
    addrs.each  do |addr|
      elems << pad("source", "==", addr)
    end
    return client.get_orders(elems, "or")
  end
end


XCP_UNIT = 100000000
puts Counterparty.new.get_orders_by_addrs(["n2pZKpTdt2cuuibnCyKtuK1f8yNRjYvQnm"])
#puts Counterparty.new.create_send("n1YYLhLyn94UMEdMdzXwdjnGBU1LXhC6d8", "KOJIEYOUCOIN", 99)
#puts Counterparty.new.create_order("KOJIEYOUCOIN", 100, "XCP", 10 * XCP_UNIT)

#Counterparty.new.import_privkey
# puts Counterparty.new.passphrase_to_address("spill sometimes image cloud floor thrown peel freedom leap also mention accept")
#
# # Counterparty.new.import_privkey
# # puts Counterparty.new.asset_balance("TOMMYZV")
#
#Counterparty.new.give_coin("KOBEARBEAR", "myRvN6vjWorHHBfbFWCnPVKbQ21pS1wE2D",10000)
#puts Counterparty.new.create_asset("YouCoin", "You kOIN", 2000)
#puts Counterparty.new.get_asset_info(['KOJIEYOUCOIN'])
#puts Counterparty.new.create_burn(100000)
#client = RPC::JSON::Client.new($CP_CONFIG[:url])
#result = client.get_balances({field:"address", op:"==",value:"n3u2zXCj3SUCTAwG8gx2skqb6muBRjcb7W"})
#move_coin("myRvN6vjWorHHBfbFWCnPVKbQ21pS1wE2D", "n3u2zXCj3SUCTAwG8gx2skqb6muBRjcb7W", name, quantity)
#puts sCounterparty.new.give_coin("KOBEARBEAR", "myRvN6vjWorHHBfbFWCnPVKbQ21pS1wE2D",10000)
