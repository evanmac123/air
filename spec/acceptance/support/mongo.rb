RSpec.configure do |config|
  config.before(:each) do
    User::SegmentationData.delete_all
  end
end
