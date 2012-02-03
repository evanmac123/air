require 'spec_helper'

describe Admin::UsersController do
  describe "#create" do
    before(:each) do
      @demo = Factory :demo
      @params = {:demo_id => @demo.id, :user => Factory.attributes_for(:user), :set_claim_code => true}
      # @controller.current_user = Factory :site_admin
      user = Factory :site_admin
      visit sign_in_path
      user.update_password "foobar", "foobar"

      
      fill_in "session[email]", :with => user.email
      fill_in "session[password]", :with => "foobar"
      click_button "Let's play!"
    end

    describe "with claim code requested" do
      before(:each) do
        @params[:set_claim_code] = true
        request.env["HTTP_REFERER"] = '/' # since we use redirect :back
      end

      it "should set a claim code" do
        pending
        post :create, @params

        user = User.order('created_at DESC').first
        user.claim_code.should_not be_nil
      end
    end
  end
end
