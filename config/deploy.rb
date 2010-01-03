set :application, "beermat"
set :repository, "git://github.com/threez/beermat.git"
set :scm, "git"
set :user, application
set :domain, "symbol-group.com"
set :use_sudo, false
set :deploy_to, "/home/#{application}"

role :web, domain
role :app, domain
role :db,  domain, :primary => true

namespace :deploy do
  task(:start) {}
  task(:stop) {}
  task(:restart, :roles => :app, :except => { :no_release => true }) do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end