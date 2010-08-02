require "stats"

CONFIG = "db/remote/config.yaml"
STOCK = "db/remote/stock.yaml"

db0 = BeerManager::Database.new CONFIG, STOCK, "db/remote/protocols.dat"
db1 = BeerManager::Database.new CONFIG, STOCK, "db/remote/protocols.dat.1"

db = BeerManager::Database.merge(CONFIG, STOCK, "db/remote/merged.dat", db0, db1)

if __FILE__ == $0
  for year in db.all_years do
    protocols = db.filter_by_year(2010)
    months = protocols.map do |protocol|
      BeerManager::Stats.each_month_sum(protocol) do |count, drink|
        count * drink.liter
      end
    end
    p BeerManager::Stats.merge_months(months).sum / 12
    p BeerManager::Stats.merge_months(months)
  
    months = protocols.map do |protocol|
      BeerManager::Stats.each_month_sum(protocol) do |count, drink|
        count * drink.price
      end
    end
    p BeerManager::Stats.merge_months(months).sum / 12
    p BeerManager::Stats.merge_months(months)
  end
end
