require 'spec_helper'

describe Beermat::Drink do
  it "should be possible to create a drink instance" do
    Beermat::Drink.new
  end
  
  context "with drink" do
    before(:each) do
      @drink = Beermat::Drink.new
    end

    it "has a name attribute" do
      @drink.name.should be_nil
      @drink.name = "Duff Beer 0,5l"
      @drink.name.should == "Duff Beer 0,5l"
    end

    it "has a price attribute" do
      @drink.price.should be_nil
      @drink.price = 1
      @drink.price.should == 1
    end

    it "has a capacity attribute" do
      @drink.capacity.should be_nil
      @drink.capacity = "0.5l"
      @drink.capacity.should == "0.5l"
    end
    
    it "has a warning_red attribute" do
      @drink.warning_red.should be_nil
      @drink.warning_red = 5
      @drink.warning_red.should == 5
    end
    
    it "has a warning_yellow attribute" do
      @drink.warning_yellow.should be_nil
      @drink.warning_yellow = 10
      @drink.warning_yellow.should == 10
    end
    
    it "has a picture_url attribute" do
      @drink.picture_url.should be_nil
      @drink.picture_url = "http://images.org/duff.png"
      @drink.picture_url.should == "http://images.org/duff.png"
    end
  end
  
  context "serialization" do
    it "should be possible to load a drink from a file" do
      @drink = Beermat::Drink.load(yaml_fixture_path(:drinks, :duff))
      @drink.name.should == "Duff Beer 0,5l"
      @drink.price.should == 1
      @drink.capacity.should == "0.5l"
      @drink.warning_red.should == 5
      @drink.warning_yellow.should == 10
      @drink.picture_url.should == "http://images.org/duff.png"
    end
    
    it "should be possible to save a drink file" do
      @drink = Beermat::Drink.new
      @drink.name = "Duff Beer 0,5l"
      @drink.price = 1
      @drink.capacity = "0.5l"
      @drink.warning_red = 5
      @drink.warning_yellow = 10
      @drink.picture_url = "http://images.org/duff.png"
      file = Tempfile.new('duff')
      @drink.save(file.path)
      file.read.should == File.read(yaml_fixture_path(:drinks, :duff))
    end
  end
end
