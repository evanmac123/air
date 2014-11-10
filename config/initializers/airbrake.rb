Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY'] || 'fake_airbrake_key'
end
