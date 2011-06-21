namespace :report do
  desc "Send an activity dump about the game specified by ABOUT to the e-mails (comma-separated) specified by TO"
  task :activity => :environment do
    Report::Activity.new(ENV['ABOUT']).email_to(ENV['TO'])
  end
end
