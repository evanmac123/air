require 'spec_helper'

require 'ruby-debug' unless ENV['NO_DEBUGGER']
require 'pry'        unless ENV['NO_DEBUGGER']

describe User, "#relationship_with" do
  before(:each) do
    @demo = FactoryGirl.create(:demo)
    @left_user = FactoryGirl.create(:user, :demo_id => @demo.id)
    @right_user = FactoryGirl.create(:user, :demo_id => @demo.id)
  end

  it "should show who you don't have any connections with" do

    @left_user.relationship_with(@right_user).should == "none"
    @right_user.relationship_with(@left_user).should == "none"
    @left_user.befriend(@right_user)
    @left_user.relationship_with(@right_user).should == "a_initiated"
    @right_user.relationship_with(@left_user).should == "b_initiated"
    @right_user.friendships.first.accept
    @left_user.relationship_with(@right_user).should == "friends"
    @right_user.relationship_with(@left_user).should == "friends"
  end
  
  it "should not puke when given only half of a relationship" do

    Friendship.create(:user_id => @left_user.id, :friend_id => @right_user.id, :state => 'pending')
    @right_user.relationship_with(@left_user).should == "unknown"
  end
end
  