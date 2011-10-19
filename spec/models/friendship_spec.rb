require 'spec_helper'

describe Friendship do
  before(:each) do
    Twilio::SMS.stubs(:create)
  end

  it { should belong_to(:user) }
  it { should belong_to(:friend) }

  describe "on create" do
    describe "request index" do
      before do
        @followed = Factory :user
        3.times {Factory :accepted_friendship, :friend => @followed}
        3.times {Factory :friendship}
      end

      context "when no other pending Friendships exist for this user" do
        it "should be 1" do
          Friendship.where(:friend_id => @user, :state => 'pending').should be_empty

          pending_friendship = Factory :friendship, :friend => @followed
          pending_friendship.request_index.should == 1
        end
      end

      context "when other pending Freindships exist for this user" do
        it "should be 1 greater than the greatest existing request index" do
          [1,3,5,7].each do |i|
            friendship = Factory :friendship, :state => 'pending', :friend => @followed
            friendship.request_index = i
            friendship.save!
          end

          pending_friendship = Factory :friendship, :friend => @followed
          pending_friendship.request_index.should == 8
        end
      end
    end

  end

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
