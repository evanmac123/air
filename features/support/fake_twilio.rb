require 'sinatra/base'

class FakeTwilioApp < Sinatra::Base
  before do
    content_type :json
  end

  post "/2010-04-01/Accounts/#{FAKE_TWILIO_ACCOUNT_SID}/SMS/Message" do
    FakeTwilio::SMS.post(params)
    {
      :account_sid  => "AC5ef872f6da5a21de157d80997a64bd33",
      :api_version  => "2010-04-01",
      :body         => "Jenny please?! I love you <3",
      :date_created => "Wed, 18 Aug 2010 20:01:40 +0000",
      :date_sent    => nil,
      :date_updated => "Wed, 18 Aug 2010 20:01:40 +0000",
      :direction    => "outbound-api",
      :from         => "+14158141829",
      :price        => nil,
      :sid          => "SM90c6fc909d8504d45ecdb3a3d5b3556e",
      :status       => "queued",
      :to           => "+14159352345",
      :uri          => "/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages/SM90c6fc909d8504d45ecdb3a3d5b3556e.json"
    }.to_json
  end
end

ShamRack.at('api.twilio.com', 443).rackup do
  run FakeTwilioApp
end

module FakeTwilio
  class SMS
    @@messages = []

    def self.post(message)
      @@messages << message
      Rails.logger.info "SMS: --------- #{message} ---------"
    end

    def self.clear_all
      @@messages = []
      Rails.logger.info "SMS: --------- RESET ---------"
    end

    def self.has_text?(phone, body)
      @@messages.any? do |message|
        message["to"]   == phone &&
        message["body"] == body
      end
    end
  end
end

Before do
  FakeTwilio::SMS.clear_all
end
