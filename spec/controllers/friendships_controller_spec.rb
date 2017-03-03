require 'spec_helper'

describe FriendshipsController do
  it "should not let a user try to friend someone without a board in common" do
    subject.stubs(:ping)

    friender = FactoryGirl.create(:user)
    friendee = FactoryGirl.create(:user)

    sign_in_as(friender)
    post :create, user_id: friendee.slug

    expect(response.request.flash[:failure]).to eq(I18n.t('flashes.failure_friendships_need_common_board'))
    expect(Friendship.count).to eq(0)
  end
end
