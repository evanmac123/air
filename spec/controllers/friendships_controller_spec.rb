require 'spec_helper'

describe FriendshipsController do
  it "should not let a user try to friend someone without a board in common" do
    friender = FactoryGirl.create(:user)
    friendee = FactoryGirl.create(:user)
    
    sign_in_as(friender)
    post :create, user_id: friendee.slug

    response.should be_not_found
    Friendship.count.should == 0
  end
end
