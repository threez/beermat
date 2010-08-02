require "config"

module BeerManager
  class Database
    def all_protocols
      protocols = []
      for person in people do
        for protocol in person.protocols do
          protocols << protocol
        end
      end
      protocols
    end
    
    def filter_by_year(year, protocols = nil)
      protocols ||= all_protocols
      protocols.select { |protocol| protocol.year == year }
    end
    
    def all_years(protocols = nil)
      protocols ||= all_protocols
      protocols.map { |protocol| protocol.year }.uniq!
    end
    
    def export_as_csv
      csv = ""
      csv << "Name;Bier;Datum;Anzahl;Preis;Liter;Eingeladen von\n"
      day_sec = 60 * 60 * 24 # one day
      for person in people do
        for protocol in person.protocols do
          first_date = Time.gm(protocol.year, 1, 1)
          for day in protocol.days do
            if day > 0
              csv << ("%s;%s;%s;%d;%s;%s;%s\n" % [
                person.name, protocol.drink.name, first_date.strftime("%d.%m.%Y"),
                day, (day * protocol.drink.price).to_s.gsub(".", ","),
                (day * protocol.drink.liter.to_f).to_s.gsub(".", ","),
                person.invited_by
              ])
            end
            first_date += day_sec
          end
        end
      end
      csv
    end
  end
  
  class Protocol
    def sum_between(start_time, end_time) # :yields: count, drink
      start_index = (start_time - Time.gm(year)) / DAY
      end_index = (end_time - Time.gm(year)) / DAY
      self[start_index..end_index].inject(0) do |i, count| 
        i += yield(count, drink)
      end
    end
  end
  
  module Stats
    def self.get_moths_for(year)
      current_month = 1
      months = []
      12.times do |i|
        start_time = Time.gm(year, current_month)
        if i == 11
          end_time = Time.gm(year + 1, 1)
        else
          end_time = Time.gm(year, current_month + 1)
        end
        current_month += 1
        months << [start_time, end_time]
      end
      months
    end
    
    def self.each_month_sum(protocol, &block)
      sums = []
      for month in get_moths_for(protocol.year) do
        start_time, end_time = month
        sums << protocol.sum_between(start_time, end_time, &block) 
      end
      sums
    end
    
    def self.merge_months(months)
      sum = months.shift
      for month in months do
        sum.size.times do |i|
          sum[i] += month[i]
        end
      end
      sum
    end
  end
end
