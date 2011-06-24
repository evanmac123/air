require 'spec_helper'

# Hack to allow us to use regular controller tests to test SmsController 
# (which is an ActionController::Metal).
class SmsController
  include ActionController::UrlFor
  include ActionController::Testing
  include Rails.application.routes.url_helpers
  include ActionController::Compatibility
end

describe SmsController do
  describe "#create" do
    before(:each) do
      @params = {'From' => '+14152613077', 'Body' => 'ate kitten'}
    end

    context "when properly authenticated as Twilio" do
      it "should return some text with a 200 status" do
        post 'create', @params.merge({'AccountSid' => Twilio::ACCOUNT_SID})
        response.status.should == 200
        response.content_type.should == 'text/plain'
        response.body.should_not be_blank
      end
    end

    context "when authentication as Twilio fails" do
      it "should return a blank 404" do
        post :create, @params.merge({'AccountSid' => Twilio::ACCOUNT_SID + "youbrokeit"})

        response.status.should == 404
        response.body.should be_blank
      end
    end
  end
end
