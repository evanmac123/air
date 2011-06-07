require 'cucumber/rake/task'
require 'rcov/rcovtask'

namespace :rcov do
  
  rcov_opts = ['-T','--exclude gems/*,rcov*,features/step_definitions/web_steps.rb']
  
  desc 'Measures cucumber coverage'
  Cucumber::Rake::Task.new(:features) do |t|    
    t.rcov = true
    t.rcov_opts = rcov_opts
    t.rcov_opts << '-o coverage.features'
  end
  
  desc 'Measures shoulda coverage'  
  Rcov::RcovTask.new(:tests) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/unit/*_test.rb','test/functional/*_test.rb','test/unit/helpers/*_test.rb']
    t.rcov_opts = rcov_opts
    t.output_dir = "coverage.tests"
  end

  desc 'Measures all coverage'  
  task :all do
    ["features", "tests"].each{ |task| Rake::Task["rcov:#{task}"].invoke }
  end
end
