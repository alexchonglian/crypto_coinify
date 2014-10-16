begin
  PaymentEngines.register(CatarsePaypalExpress::PaymentEngine.new)
  puts "Registered: " + PaymentEngines.engines.to_s
  puts "Registered: " + PaymentEngines.engines[0].name
rescue Exception => e
  puts "Error while registering payment engine: #{e}"
end
