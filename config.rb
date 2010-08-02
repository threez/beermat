require "yaml"
require "time"
require "logger"

class Array
  def sum
    inject(0) { |i, d| i += d }
  end
end

module BeerManager
  def self.log
    @log ||= ::Logger.new(STDOUT)
  end
  
  class Protocol
    DAYS = 365
    DAY = 24 * 60 * 60
    attr_accessor :year, :days, :drink
    
    def initialize(year, drink, days)
      @year, @drink, @days = year, drink, days
    end
    
    def self.create(year, drink)
      days = Array.new(DAYS).map { 0 }
      new(year, drink, days)
    end
    
    def [](day)
      @days[day]
    end
    
    def []=(day, new_value)
      @days[day] = new_value
    end
    
    def date(day)
      Time.gm(@year) + day * DAY
    end
    
    def merge(protocol)
      DAYS.times do |day|
        if protocol[day] > 0
          BeerManager.log.info "      add day #{date(day)}: #{self[day]} + #{protocol[day]} = #{self[day] + protocol[day]}"
        end
        self[day] += protocol[day]
      end
    end
    
    def sum
      days.sum
    end
  end
  
  class Person
    ID = "ID"
    PHOTO = "Photo"
    INVITED_BY = "Eingeladen-von"
    
    attr_accessor :name, :photo, :invited_by, :ref_id
    
    def initialize
      @protocols = {}
    end
    
    def current_year
      Time.now.year
    end
    
    def [](drink)
      # does the year exist? if no, create
      unless @protocols[current_year]
        @protocols[current_year] = []
      end
      
      # does the drink protocol exists? if no, create
      unless protocol_for_drink(current_year, drink)
        @protocols[current_year] << Protocol.create(current_year, drink)
      end
      
      protocol_for_drink(current_year, drink)
    end
    
    def protocols
      @protocols.values.flatten
    end
    
    def protocol_for_drink(year, drink)
      return nil if @protocols[year].nil?
      @protocols[year].find { |d| d.drink.ref_id == drink.ref_id }
    end
    
    def payday
      if @protocols[current_year]
        return @protocols[current_year].map do |protocol|
          protocol.sum * protocol.drink.price
        end.sum
      else
        return 0.0
      end
    end
    
    def add_drink_at(time, drink)
      self[drink][time.yday] += 1
    end
    
    def self.parse(name, data)
      person = new()
      person.name = name
      person.ref_id = data[ID]
      person.photo = data[PHOTO] ? data[PHOTO] : "images/empty_avatar.gif"
      person.invited_by = data[INVITED_BY]
      person
    end
    
    def invitor(people)
      people.select { |p| p.name == invited_by } if invited_by
    end
    
    def add_protocol(year, drink, days)
      @protocols[year] = [] unless @protocols[year]
      @protocols[year] << Protocol.new(year, drink, days)
    end
    
    def <<(protocol)
      @protocols[protocol.year] = [] unless @protocols[protocol.year]
      @protocols[protocol.year] << protocol
    end
  
    def to_hash
      hash = {
        ID => ref_id,
        PHOTO => photo
      }
      hash[INVITED_BY] = invited_by if invited_by
      hash
    end
  end
  
  class Drink
    ID = "ID"
    PRICE = "Preis"
    QUANTITY_PER_UNIT = "Menge-pro-Einheit"
    WARNING_YELLOW = "Warnung-gelb"
    WARNING_RED = "Warnung-rot"
    PHOTO = "Photo"
    MAX_QUANTITY = "Maximale-Menge"
  
    attr_accessor :name, :price, :quantity_per_unit, :photo, :quantity,
                  :warning_yellow, :warning_red, :ref_id, :max_quantity
                  
    def self.parse(name, data)
      drink = new()
      drink.name = name
      drink.ref_id = data[ID]
      drink.price = data[PRICE]
      drink.quantity_per_unit = data[QUANTITY_PER_UNIT]
      drink.warning_yellow = data[WARNING_YELLOW]
      drink.warning_red = data[WARNING_RED]
      drink.max_quantity = data[MAX_QUANTITY]
      drink.photo = data[PHOTO]
      drink
    end
    
    def volume
      if quantity_per_unit =~ /(\d+.\d+)(\w+)/ 
        "%0.2f#{$2}" % [$1.to_f * quantity]
      end
    end
    
    def liter
      if quantity_per_unit =~ /(\d+.\d+)(\w+)/ 
        $1.to_f
      end
    end
    
    def warning_css
      if quantity <= warning_red
        :warning_red
      elsif quantity <= warning_yellow
        :warning_yellow
      end
    end
    
    def value
      quantity * price
    end
    
    def to_hash
      {
        ID => ref_id,
        PRICE => price,
        QUANTITY_PER_UNIT => quantity_per_unit,
        WARNING_YELLOW => warning_yellow,
        WARNING_RED => warning_red,
        MAX_QUANTITY => max_quantity, 
        PHOTO => photo
      }
    end
  end

  class Database
    UNITS = "Einheiten"
    PEOPLE = "Personen"
    DRINKS = "Getraenke"
    PASSWD = "Passwort"
    
    attr_reader :people, :drinks
    
    def initialize(config_path, stock_path, protocol_path, do_refresh = true)
      @config_path = config_path
      @stock_path = stock_path
      @protocol_path = protocol_path
      if do_refresh
        refresh!
      else
        @people = []
        @drinks = []
      end
    end
    
    def refresh!
      load_config(@config_path)
      load_stock(@stock_path, @drinks)
      load_protocol(@protocol_path, @people, @drinks)
    end
    
    def load_config(path)
      BeerManager.log.info "load config #{path}"
      file_content = ::File.read(path)
      hash = YAML.load(file_content)
      @people, @drinks, @units = [], [], {}
      
      hash.each do |key, value|
        case key
          when UNITS
            @units = value
          when PEOPLE
            value.each do |person_name, person_data|
              @people << Person.parse(person_name, person_data)
            end
          when DRINKS
            value.each do |drink_name, drink_data|
              @drinks << Drink.parse(drink_name, drink_data)
            end
          when PASSWD
            @passwd = value
        end
      end
    end
    
    def load_stock(stock_path, drinks)
      BeerManager.log.info "load stock #{stock_path}"
      stock = YAML.load(::File.read(stock_path))
      for drink in drinks
        drink.quantity = stock[drink.ref_id]
      end
    end
    
    def load_protocol(protocol_path, people, drinks)
      BeerManager.log.info "load protocol #{protocol_path}"
      ::File.open(protocol_path, "r") do |file|
        while !file.eof?
          # read one protocol
          person_id = file.read 2 # 2 bytes user id 
          drink_id = file.read 2 # 2 bytes drink id
          year = file.read(2).unpack("n").first # big endian short (2 byte)
          days = file.read(Protocol::DAYS).unpack("c" * Protocol::DAYS)
          file.read(1) # end of line
          
          # add protocol to user
          person = find_person_by_id(person_id)
          drink = find_drink_by_id(drink_id)
          person.add_protocol(year, drink, days)
        end
      end if ::File.exist? protocol_path
    end
    
    def find_person_by_id(id)
      people.find { |p| p.ref_id == id }
    end
    
    def find_drink_by_id(id)
      drinks.find { |d| d.ref_id == id }
    end
    
    def save!
      BeerManager.log.info "save config, stock and protocols"
      save_config(@config_path)
      save_stock(@stock_path)
      save_protocol(@protocol_path)
    end
    
    def save_config(path)
      BeerManager.log.info "save config #{path}"
      hash = {
        UNITS => @units,
        PASSWD => @passwd,
        PEOPLE => {},
        DRINKS => {}
      }
      @people.each do |person|
        hash[PEOPLE][person.name] = person.to_hash
      end
      @drinks.each do |drink|
        hash[DRINKS][drink.name] = drink.to_hash
      end        
      
      ::File.open(path, "w") do |file|
        file.write(YAML.dump(hash))
      end
    end
    
    def save_stock(stock_path)
      BeerManager.log.info "save stock #{stock_path}"
      ::File.open(stock_path, "w") do |file|
        hash = {}
        
        for drink in drinks
          hash[drink.ref_id] = drink.quantity
        end
        
        file.write(YAML.dump(hash))
      end
    end
    
    def save_protocol(protocol_path)
      BeerManager.log.info "save protocol #{protocol_path}"
      ::File.open(protocol_path, "w") do |file|
        @people.each do |person|
          person.protocols.each do |protocol|
            file.write(person.ref_id)
            file.write(protocol.drink.ref_id)
            file.write([protocol.year].pack("n"))
            file.write(protocol.days.pack("c" * Protocol::DAYS))
            file.write("\n")
          end
        end
      end
    end
    
    def save_changed_stock_and_protocol(stock_path, protocol_path)
      BeerManager.log.info "save stock and protocols"
      save_stock(stock_path)
      save_protocol(protocol_path)
    end
    
    def add_drink_for(person_id, drink_id)
      person = find_person_by_id(person_id)
      drink = find_drink_by_id(drink_id)
      BeerManager.log.info "add drink #{drink.name} for #{person.name}"
      drink.quantity -= 1
      person.add_drink_at(Time.now, drink)
    end
    
    def merge(database)
      merge_drinks(database)
      merge_people(database)
    end
    
    def merge_people(database)
      for person in database.people do
        if found_person = find_person_by_id(person.ref_id)
          BeerManager.log.info "  merge person #{person.name}..."
          for protocol in person.protocols do
            if protocol_found = found_person.protocol_for_drink(protocol.year, protocol.drink)
              BeerManager.log.info "    merge protocol #{protocol.year} for '#{protocol.drink.name}'..."
              protocol_found.merge(protocol)
            else
              BeerManager.log.info "    add protocol #{protocol.year} for '#{protocol.drink.name}'..."
              found_person << protocol
            end
          end
        else
          BeerManager.log.info "  add person #{person.name}..."
          for protocol in person.protocols do
            BeerManager.log.info "     add protocol #{protocol.year} for '#{protocol.drink.name}'..."
          end
          @people << person
        end
      end
    end
    
    def merge_drinks(database)
      for drink in database.drinks do
        if find_drink_by_id(drink.ref_id).nil?
          BeerManager.log.info "  add drink #{drink.name}..."
          @drinks << drink
        end
      end
    end
    
    def self.merge(config_path, stock_path, protocol_path, *databases)
      merged_database = Database.new(config_path, stock_path, protocol_path, false)
      for database in databases do
        BeerManager.log.info "merge database..."
        merged_database.merge(database)
      end
      merged_database      
    end
  end
end
