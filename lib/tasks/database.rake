namespace :db do
  task :wipetest => [:use_test_env, :drop, :create, "schema:load"] do

  end
  
  task :use_test_env do
    Rails.env = 'test'
  end
end
