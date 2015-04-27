namespace :bulk_load do
  desc "Delete all files from eligibility bucket"
  task :purge_eligibility_files => :environment do
    EligibilityFilePurger.new.purge!
  end
end
