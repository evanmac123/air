require 'spec_helper'


describe ActsController do
  describe "#create" do
    before(:each) do
      rule =FactoryGirl.create(:rule)
      rule_value = FactoryGirl.create(:rule_value, rule: rule)
      suzie = FactoryGirl.create(:claimed_user, password: 'password')
      request.env['HTTP_REFERER'] = 'blah blah blah'  # This is here so we can redirect :back
      sign_in_as(suzie) # This is the default Clearance helper
    end

    context "when acting via the web" do
      it "should return 'success' with a 200 status" do
        entered_text = "something else entirely"
        post :create, :act => {code: entered_text}
        # There is a redirect in the controller to :back, so you should never get 200
        response.status.should == 302
        response.body.should_not be_blank
      end
    end
  end

  describe "index" do
    context "when there's a guest user, but the persistent message is disabled for the board" do
      it "doesn't show it" do
        demo = FactoryGirl.create(:demo, is_public: true)
        $rollout.activate_user(:skip_persistent_message, demo)

        get :index, public_slug: demo.public_slug
        flash[:success].should_not be_present
      end
    end
  end

  it 'should reject attempts to sign in with an invalid security token (as found in tile links in digest email)' do
    user = FactoryGirl.create :user
    get :index, tile_token: '123456789', user_id: user.id
    response.should redirect_to sign_in_url
  end
end

