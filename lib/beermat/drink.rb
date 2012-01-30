module Beermat
  class Drink
    attr_accessor :name, :price, :capacity, :warning_red, 
                  :warning_yellow, :picture_url
    
    def self.load(path)
      profile = new
      YAML.load(File.read(path)).each do |key, value|
        profile.send("#{key}=", value)
      end
      profile
    end
    
    def save(path)
      File.open(path, "w") do |f|
        f.write(YAML.dump(
          "name" => name,
          "price" => price,
          "capacity" => capacity,
          "warning_red" => warning_red,
          "warning_yellow" => warning_yellow,
          "picture_url" => picture_url
        ))
      end
    end
  end
end
