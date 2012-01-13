namespace :db do
  task :wipe do
    puts "Dropping"
    system("bundle exec rake db:drop RAILS_ENV=test")
    puts "Creating"
    system("bundle exec rake db:create RAILS_ENV=test")
    puts "Migrating"
    system("bundle exec rake db:schema:load RAILS_ENV=test")    
    puts "Done"
  end
end
