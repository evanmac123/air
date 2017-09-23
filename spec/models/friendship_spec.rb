require 'spec_helper'

describe Friendship do
  before(:each) do
    FakeTwilio::Client.stubs(:messages)
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:friend) }


  describe "after create" do
    context "when the friended user has no phone number" do
      before :each do
        @user_1 = FactoryGirl.create :user
        @user_2 = FactoryGirl.create :user
        @user_3 = FactoryGirl.create :user
        @friend = FactoryGirl.create :user, :phone_number => '', :notification_method => 'both'
      end

      it "should not try to send an SMS to that blank number" do
        FactoryGirl.create(:friendship, user: @user_1, friend: @friend)
        expect(FakeTwilio::Client).to have_received(:messages).never
      end

      it "should set both reciprocal friendships to the same request index" do
        @user_1.befriend(@friend)
        initiated_1 = Friendship.where(:user_id => @user_1.id, :friend_id => @friend.id).first
        expect(initiated_1.request_index).to eq(1)
        pending_1 = Friendship.where(:user_id => @friend.id, :friend_id => @user_1.id).first
        expect(pending_1.request_index).to eq(1)
        # Second round
        @user_2.befriend(@friend)
        initiated_2 = Friendship.where(:user_id => @user_2.id, :friend_id => @friend.id).first
        expect(initiated_2.request_index).to eq(2)
        pending_2 = Friendship.where(:user_id => @friend.id, :friend_id => @user_2.id).first
        expect(pending_2.request_index).to eq(2)
        # Now manually bump the indices and test a third round
        initiated_2.request_index = 9
        initiated_2.save
        pending_2.request_index = 9
        pending_2.save
        # Third round
        @user_3.befriend(@friend)
        initiated_3 = Friendship.where(:user_id => @user_3.id, :friend_id => @friend.id).first
        expect(initiated_3.request_index).to eq(10)
        pending_3 = Friendship.where(:user_id => @friend.id, :friend_id => @user_3.id).first
        expect(pending_3.request_index).to eq(10)
      end
    end
  end

end
