require 'spec_helper'


describe ActsController do
  describe "index" do
    it "should send appropriate pings" do
      subject.stubs(:ping)
      subject.stubs(:saw_welcome_pop_up_ping)
      demo = FactoryGirl.create(:demo, is_public: true)

      get :index, public_slug: demo.public_slug

      expect(subject).to have_received(:saw_welcome_pop_up_ping)
    end

    context "when there's a guest user, but the persistent message is disabled for the board" do
      it "doesn't show it" do
        subject.stubs(:ping)

        demo = FactoryGirl.create(:demo, is_public: true)
        $rollout.activate_user(:skip_persistent_message, demo)

        get :index, public_slug: demo.public_slug
        flash[:success].should_not be_present
      end
    end
  end

  it 'should reject attempts to sign in with an invalid security token (as found in tile links in digest email)' do
    subject.stubs(:ping)

    user = FactoryGirl.create :user
    get :index, tile_token: '123456789', user_id: user.id
    response.should redirect_to sign_in_url
  end
end
