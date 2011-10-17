require 'spec_helper'

describe Friendship do
  before(:each) do
    Twilio::SMS.stubs(:create)
  end

  it { should belong_to(:user) }
  it { should belong_to(:friend) }

  describe "after create" do
    context "when the friended user has no phone number" do
      before :each do
        @user = Factory :user
        @friend = Factory :user, :phone_number => '', :notification_method => 'both'
      end

      it "should not try to send an SMS to that blank number" do
        friendship = Factory :friendship, :user => @user, :friend => @friend
        Twilio::SMS.should_not have_received(:create)
      end
    end
  end
end
