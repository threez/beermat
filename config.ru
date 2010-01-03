require 'rubygems'
require 'sinatra'
require 'yaml'

Sinatra::Application.set :run => false, 
                         :environment => :production

global_password = YAML.load(::File.read("db/config.yaml"))["Passwort"]

log = File.new("log/sinatra.log", "a")
log.sync = true
$stdout.reopen(log)
$stderr.reopen(log)

require 'webserver'
use Rack::Auth::Basic do |username, password|
  username == '' && password == global_password
end
run Sinatra::Application