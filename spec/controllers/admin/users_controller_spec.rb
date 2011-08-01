describe Admin::UsersController do
  describe "#create" do
    before(:each) do
      @demo = Factory :demo
      @params = {:demo_id => @demo.id, :user => Factory.attributes_for(:user)}
      @controller.current_user = Factory :site_admin
    end

    describe "with claim code requested" do
      before(:each) do
        @params[:set_claim_code] = true
        request.env["HTTP_REFERER"] = '/' # since we use redirect :back
      end

      it "should set a claim code" do
        post :create, @params

        user = User.order('created_at DESC').first
        user.claim_code.should_not be_nil
      end
    end
  end
end
