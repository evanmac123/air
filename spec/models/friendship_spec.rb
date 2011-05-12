require 'spec_helper'

describe Friendship do
  before(:each) do
    SMS.stubs(:send)
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
  end
end
