RSpec.configure do |config|
  config.before(:each) do
    Delayed::Job.delete_all
  end
end
