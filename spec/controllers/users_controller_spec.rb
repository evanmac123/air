require 'spec_helper'

describe ::UsersController do
  describe "#show" do
    before(:each) do
      subject.stubs(:ping)
      @demo = FactoryGirl.create :demo
      @user_we_are_viewing = FactoryGirl.create :claimed_user, :demo => @demo
      @friend = FactoryGirl.create :claimed_user, :demo => @demo
      @pending_friend = FactoryGirl.create :claimed_user, :demo => @demo
      @pending_friend.befriend @user_we_are_viewing
      @user_we_are_viewing.befriend @friend
      @friend.accept_friendship_from @user_we_are_viewing
      @random_user = FactoryGirl.create :claimed_user, :demo => @demo
      $test_force_ssl = false
    end

    it "should allow admin to view information" do
      site_admin = FactoryGirl.create(:site_admin, demo: @demo)
      sign_in_as(site_admin)
      get :show, id: @user_we_are_viewing.slug
      expect(response).to be_success
      expect(assigns(:display_user_stats)).to be_truthy
      expect(assigns(:display_pending_friendships)).to be_truthy
    end

    it "should allow friend to view information" do
      sign_in_as(@friend)
      get :show, id: @user_we_are_viewing.slug
      expect(response).to be_success
      expect(assigns(:display_user_stats)).to be_truthy
      expect(assigns(:display_pending_friendships)).to be_falsey
    end

    it "should not allow random people to view information" do
      sign_in_as(@random_user)
      get :show, :id => @user_we_are_viewing.slug
      expect(response).to be_success
      expect(assigns(:display_user_stats)).to be_falsey
      expect(assigns(:display_pending_friendships)).to be_falsey
    end
  end
end
