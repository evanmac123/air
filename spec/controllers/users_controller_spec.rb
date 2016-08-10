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
      @controller.current_user = FactoryGirl.create :site_admin, :demo => @demo
      @current_user = @controller.current_user
      get :show, :id => @user_we_are_viewing.slug
      response.should be_success
      assigns(:display_user_stats).should be_true
      assigns(:display_pending_friendships).should be_true
    end

    it "should allow friend to view information" do
      @controller.current_user = @friend
      @current_user = @controller.current_user
      get :show, :id => @user_we_are_viewing.slug
      response.should be_success
      assigns(:display_user_stats).should be_true
      assigns(:display_pending_friendships).should be_false  # friends don't see others' pending friends
    end

    it "should not allow random people to view information" do
      @controller.current_user = @random_user
      @current_user = @controller.current_user
      get :show, :id => @user_we_are_viewing.slug
      response.should be_success
      assigns(:display_user_stats).should be_false
      assigns(:display_pending_friendships).should be_false
    end


  end
end
