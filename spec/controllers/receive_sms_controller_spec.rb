require 'spec_helper'

describe ReceiveSmsController do
  describe "#create" do
    before(:each) do
      @user = FactoryGirl.create(:user, phone_number: "+14152613077")
    end

    describe "when existing user responds with anything but 'stop'" do
      it "should return Twilio friendly XML and keep the user's notifications settings unchanged" do
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
      it "unsubscribes them from texts by updating their notification settings" do
        params = {
          "From" => @user.phone_number,
          "Body" => "Hi, please stop sending text messages.",
          "To"   => "+14158675309",
        }

        post "create", params

        expect(response.status).to eq(200)
        expect(response.content_type).to eq("xml")
        expect(response.body).to eq(stop_response(@user.demo.name))
        expect(@user.board_memberships.first.notification_pref).to eq(:email)
      end
    end

    describe "when an existing user responds with start" do
      it "updates their notification settings" do
        @user.board_memberships.update_all(notification_pref_cd: BoardMembership.notification_prefs[:email])

        params = {
          "From" => @user.phone_number,
          "Body" => "Hi, please start sending text messages.",
          "To"   => "+14158675309",
        }

        post "create", params

        expect(response.status).to eq(200)
        expect(response.content_type).to eq("xml")
        expect(response.body).to eq(start_response_existing_user(@user.demo.name))
        expect(@user.board_memberships.first.notification_pref).to eq(:both)
      end
    end

    describe "when an unknown user responds with start" do
      it "updates their notification settings" do
        params = {
          "From" => "+3233333333",
          "Body" => "Hi, please start sending text messages.",
          "To"   => "+14158675309",
        }

        post "create", params

        expect(response.status).to eq(200)
        expect(response.content_type).to eq("xml")
        expect(response.body).to eq(start_response_unknown_user)
      end
    end
  end
end

def stop_response(demo_name)
  simple_twiml_response("Thanks for replying. You will no longer recieve texts from #{demo_name}.")
end

def start_response_existing_user(demo_name)
  simple_twiml_response("Thanks for replying. You will now recieve text messages from #{demo_name}.")
end

def start_response_unknown_user
  simple_twiml_response("Sorry, we don't have your number in our system.")
end

def normal_response(demo_name)
  simple_twiml_response("Thanks for replying to #{demo_name}. Available commands are: 'start' and 'stop'.")
end

def simple_twiml_response(message)
  response = Twilio::TwiML::MessagingResponse.new
  response.message do |m|
    m.body(message)
  end

  response.to_s
end
