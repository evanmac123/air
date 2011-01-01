require 'sinatra/base'

class FakeTwilioApp < Sinatra::Base
  get "/2010-04-01/Accounts/#{FAKE_TWILIO_ACCOUNT_SID}/SMS/Message" do
    '<success>true</success>'
  end
end

ShamRack.at('api.twilio.com').rackup do
  run FakeTwilioApp
end
