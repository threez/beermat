module Beermat
  class Profile
    attr_accessor :firstname, :lastname, :nickname, :picture_url
    
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
          "firstname" => firstname,
          "lastname" => lastname,
          "nickname" => nickname,
          "picture_url" => picture_url
        ))
      end
    end
  end
end
