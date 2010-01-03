require "rubygems"
require "config"
require "sinatra"

CONFIG = "db/config.yaml"
STOCK = "db/stock.yaml"
PROTOCOLS = "db/protocols.dat"

before do
  @db = BeerManager::Database.new CONFIG, STOCK, PROTOCOLS
end

get "/" do
  @people = @db.people
  @drinks = @db.drinks
  
  @drink_max_quantity = @drinks.inject(0) { |i, d| i += d.max_quantity }
  @drink_quantity = @drinks.inject(0) { |i, d| i += d.quantity }
  @drinks_value = @drinks.inject(0) { |i, d| i += d.value }
  
  @drinks_percent = @drink_quantity.to_f / @drink_max_quantity.to_f * 100
  @drinks_percentage = (@drinks_percent - (@drinks_percent % 5)).to_i
  
  erb :index
end

get '/:person_id/protocol/:drink_id' do
  @db.add_drink_for(params[:person_id], params[:drink_id])
  @db.save_changed_stock_and_protocol(STOCK, PROTOCOLS)
  redirect "/"
end