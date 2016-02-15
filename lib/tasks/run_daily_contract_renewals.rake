namespace :admin do
  namespace :contracts do
    desc "Runs the weekly activity report for the previous week ending"
    task :renewals => :environment do
      ContractRenewer.execute
    end
  end
end
