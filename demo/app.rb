require 'sinatra'
require 'vendi'

set :port, 4321
set :bind, '0.0.0.0'
set :root, File.dirname(__FILE__)

enable :sessions

before do
  @vendi = Vendi.init
  @preview_config = @vendi.config_for('TestBudzPreview')
  @preview_metadata = @vendi.metadata_vending_for('TestBudzPreview')
  @preprod_config = @vendi.config_for('TestBudzPreprod')
  @preprod_metadata = @vendi.metadata_vending_for('TestBudzPreprod')
end

get "/" do
  erb :index
end

get "/preview" do
  frontail_url = 'http://localhost:9001/'
  price = @vendi.as_ada(@preview_config[:price])
  address = @preview_config[:wallet_address]
  erb :demo, { :locals => { :frontail_url => frontail_url,
                            :price => price,
                            :address => address,
                            :network => 'preview' } }
end

get "/preprod" do
  frontail_url = 'http://localhost:9002/'
  price = @vendi.as_ada(@preprod_config[:price])
  address = @preprod_config[:wallet_address]
  erb :demo, { :locals => { :frontail_url => frontail_url,
                            :price => price,
                            :address => address,
                            :network => 'preprod' } }
end

get "/api/v0/stock/:network" do
  content_type :json
  network = params[:network]

  stock = if network == 'preview'
            @preview_metadata.size
          else
            @preprod_metadata.size
          end

  {"in_stock" => stock}.to_json
end
