require 'spec_helper'

describe Beermat::Profile do
  it "should be possible to create a profile instance" do
    Beermat::Profile.new
  end
  
  context "with profile" do
    before(:each) do
      @profile = Beermat::Profile.new
    end
    
    it "has a firstname attribute" do
      @profile.firstname.should be_nil
      @profile.firstname = "Henry"
      @profile.firstname.should == "Henry"
    end
    
    it "has a lastname attribute" do
      @profile.lastname.should be_nil
      @profile.lastname = "Fischer"
      @profile.lastname.should == "Fischer"
    end
    
    it "has a nickname attribute" do
      @profile.nickname.should be_nil
      @profile.nickname = "Henni"
      @profile.nickname.should == "Henni"
    end
    
    it "has a picture url attribute" do
      @profile.picture_url.should be_nil
      @profile.picture_url = "http://some-server.com/pic2.jpg"
      @profile.picture_url.should == "http://some-server.com/pic2.jpg"
    end
  end
  
  context "serialization" do
    it "should be possible to load a profile from a file" do
      @profile = Beermat::Profile.load(yaml_fixture_path(:profiles, :hfischer))
      @profile.firstname.should == "Henry"
      @profile.lastname.should == "Fischer"
      @profile.nickname.should == "Henni"
      @profile.picture_url.should == "http://some-server.com/pic2.jpg"
    end
    
    it "should be possible to save a profile file" do
      @profile = Beermat::Profile.new
      @profile.firstname = "Henry"
      @profile.lastname = "Fischer"
      @profile.nickname = "Henni"
      @profile.picture_url = "http://some-server.com/pic2.jpg"
      file = Tempfile.new('henry.fischer')
      @profile.save(file.path)
      file.read.should == File.read(yaml_fixture_path(:profiles, :hfischer))
    end
  end
end
