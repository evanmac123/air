namespace :admin do
  desc "Runs the weekly activity report for the previous week ending"
  task :renew_invoices => :environment do
    Invoice.renew_active_invoices
  end
end
