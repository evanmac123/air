require 'spec_helper'

describe ReceiveSmsController do
  describe "#create" do
    before(:each) do
      @user = FactoryGirl.create(:user, phone_number: "+14152613077")
    end

    describe "when existing user responds with anything but 'stop'" do
      it "should return Twilio friendly XML and keep the user's phone number unchanged" do
        params = {
          "From" => @user.phone_number,
          "Body" => "Hi",
          "To"   => "+14158675309",
        }

        post "create", params

        expect(response.status).to eq(200)
        expect(response.content_type).to eq("xml")
        expect(response.body).to eq(normal_response(@user.demo.name))
      end
    end

    describe "when an unknown user response with anything" do
      it "should return Twilio friendly XML" do
        params = {
          "From" => "+14152613079",
          "Body" => "Hi from a Guest",
          "To"   => "+14158675309",
        }

        post "create", params

        expect(response.status).to eq(200)
        expect(response.content_type).to eq("xml")
        expect(response.body).to eq(normal_response("Airbo"))
      end
    end

    describe "when an existing user response with stop" do
      it "unsubscribes them from texts by removing their phone number" do
        params = {
          "From" => @user.phone_number,
          "Body" => "Hi, please stop sending text messages.",
          "To"   => "+14158675309",
        }

        post "create", params

        expect(response.status).to eq(200)
        expect(response.content_type).to eq("xml")
        expect(response.body).to eq(stop_response(@user.demo.name))
      end
    end
  end
end

def stop_response(demo_name)
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Message body=\"Thanks for replying. You will no longer recieve texts from #{demo_name}.\"/></Response>"
end

def normal_response(demo_name)
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Message body=\"Thanks for replying to #{demo_name}. Available commands are: 'stop'.\"/></Response>"
end
