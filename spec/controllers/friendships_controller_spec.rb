require 'spec_helper'

describe FriendshipsController do
  it "should not let a user try to friend someone without a board in common" do
    subject.stubs(:ping)

    friender = FactoryGirl.create(:user)
    friendee = FactoryGirl.create(:user)

    sign_in_as(friender)
    post :create, user_id: friendee.slug

    expect(response).to be_not_found
    expect(Friendship.count).to eq(0)
  end
end
