namespace :db do
  namespace :admin do

    desc "Sets explore_disabled flag to false or all demos"

    task :enable_explore => :environment do
      Demo.update_all(:explore_disabled=>false)
    end
  end
end
