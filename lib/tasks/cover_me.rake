namespace :cover_me do
  
  desc "Generates and opens code coverage report."
  task :report do
    require 'cover_me'
    CoverMe.complete!
  end
  
end

task :test do
  Rake::Task['cover_me:report'].invoke unless ENV['NO_REPORT']
end

task :spec do
  Rake::Task['cover_me:report'].invoke unless ENV['NO_REPORT']
end
