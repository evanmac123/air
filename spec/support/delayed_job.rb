RSpec.configure do |config|
  config.before(:suite) do
    Delayed::Worker.delay_jobs = false
  end

  config.before(:each) do
    Delayed::Job.delete_all
  end

  config.around(:each, delay_jobs: true) do |example|
    Delayed::Worker.delay_jobs = true

    example.run

    Delayed::Worker.delay_jobs = false
  end
end
