require 'sinatra'

require 'json'


puts "Game server started"

get '/powers.json' do |account|

  content_type :json
  [

  ].to_json

end
