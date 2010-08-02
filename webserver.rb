require "rubygems"
require "config"
require "stats"
require "sinatra"

DB_DIR = "db"
CONFIG = "#{DB_DIR}/config.yaml"
STOCK = "#{DB_DIR}/stock.yaml"
PROTOCOLS = "#{DB_DIR}/protocols.dat"

def database
  BeerManager::Database.new CONFIG, STOCK, PROTOCOLS
end

get "/" do
  @db = database
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
  @db = database
  @db.add_drink_for(params[:person_id], params[:drink_id])
  @db.save_changed_stock_and_protocol(STOCK, PROTOCOLS)
  redirect "/"
end

get '/stats' do
  @files_to_merge = Dir["#{DB_DIR}/**/*.dat*"]
  erb :stats
end

post '/stats.csv' do
  tmp = "/tmp/#{Time.now.to_i}.dat"
  databases = params[:files].map do |file|
    BeerManager::Database.new CONFIG, STOCK, file
  end
  
  merged_db = BeerManager::Database.merge(CONFIG, STOCK, tmp, *databases)
  content_type "application/x-download";
  #print "Content-Disposition:attachment;filename=name.vcs\n\n";
  merged_db.export_as_csv 
end
