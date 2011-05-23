require 'spec_helper'

describe Friendship do
  before(:each) do
    Twilio::SMS.stubs(:create)
  end

  it { should belong_to(:user) }
  it { should belong_to(:friend) }

  describe "after create" do
    it "should record a FormerFriendship with the same settings" do
      FormerFriendship.count.should == 0

      friendship = Factory :friendship

      FormerFriendship.count.should == 1
      FormerFriendship.where(:user_id => friendship.user_id, :friend_id => friendship.friend_id).should_not be_empty
    end

    context "when the friended user has no phone number" do
      before :each do
        @user = Factory :user
        @friend = Factory :user, :phone_number => ''
      end

      it "should not try to send an SMS to that blank number" do
        friendship = Factory :friendship, :user => @user, :friend => @friend
        Twilio::SMS.should_not have_received(:create)
      end
    end
  end
end
