require 'tempfile'
require File.join(File.dirname(__FILE__), "..", "lib", "beermat")

EXAMPLE_DB = File.join(File.dirname(__FILE__), "example_db")

def yaml_fixture_path(folder_name, name)
  File.join(EXAMPLE_DB, folder_name.to_s, "#{name}.yaml")
end
