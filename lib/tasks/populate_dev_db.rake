namespace :db  do
	desc "Populates development database with some workable data"
	task populate_dev: [:environment, :env_check] do
		FactoryGirl.create :user, :claimed, name: 'Herby Admin', password: 'password', password_confirmation: 'password', email: 'herby-admin@airbo.com', is_site_admin: true
		FactoryGirl.create :user, name: 'Herby Client Admin', password: 'password', password_confirmation: 'password', email: 'herby@airbo.com', is_client_admin: true
		FactoryGirl.create :user, name: 'Joe Blow', password: 'password', password_confirmation: 'password', email: 'joe@airbo.com', is_site_admin: false
	end

  task :env_check do
      raise "Hey, development only you monkey!" unless (Rails.env.development? || ENV['RACK_ENV']=="development")
    end
end
