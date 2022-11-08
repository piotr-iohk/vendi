# frozen_string_literal: true

require 'sinatra'
require 'vendi'

ENV['HOST'] ||= 'localhost'

set :port, 4321
set :bind, '0.0.0.0'
set :root, File.dirname(__FILE__)

enable :sessions

before do
  @vendi = Vendi.init
  @preview_config = @vendi.config('TestBudzPreview')
  @preview_metadata = @vendi.metadata_vending('TestBudzPreview')
  @preprod_config = @vendi.config('TestBudzPreprod')
  @preprod_metadata = @vendi.metadata_vending('TestBudzPreprod')
end

get '/' do
  erb :index
end

get '/preview' do
  frontail_url = "http://#{ENV.fetch('HOST', nil)}:9001/"
  price = @preview_config[:price]
  address = @preview_config[:wallet_address]
  policy_id = @preview_config[:wallet_policy_id]
  erb :demo, { locals: { frontail_url: frontail_url,
                         price: price,
                         address: address,
                         policy_id: policy_id,
                         network: 'preview' } }
end

get '/preprod' do
  frontail_url = "http://#{ENV.fetch('HOST', nil)}:9002/"
  price = @preprod_config[:price]
  address = @preprod_config[:wallet_address]
  policy_id = @preprod_config[:wallet_policy_id]
  erb :demo, { locals: { frontail_url: frontail_url,
                         price: price,
                         address: address,
                         policy_id: policy_id,
                         network: 'preprod' } }
end

get '/api/v0/stock/:network' do
  content_type :json
  network = params[:network]

  stock = if network == 'preview'
            @preview_metadata.size
          else
            @preprod_metadata.size
          end

  { 'in_stock' => stock }.to_json
end
