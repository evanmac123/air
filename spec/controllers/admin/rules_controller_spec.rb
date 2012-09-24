require 'spec_helper'
include SteakHelperMethods

describe Admin::RulesController do
  describe "#create" do
    before(:each) do
      @demo = FactoryGirl.create :demo
      @params = {:demo_id => @demo.id, 
                 :rule =>
                    {"primary_value"=>"yes, man",
                     "secondary_values"=>{"0"=>""},
                     "points"=>"3",
                     "reply"=>"rrrreeepply",
                     "description"=>"dee",
                     "alltime_limit"=>"",
                     "referral_points"=>"",
                     "suggestible"=>"1"}
                }
      clearance_signin_as_admin
      request.env["HTTP_REFERER"] = admin_demo_rules_path(@demo.id) # required so we can redirect :back
    end

    it "should update a rule" do
      @params.delete(:demo_id)
      @params[:id]
    end

    it "should give a reasonable response with a short reply" do
      post :create, @params
      response.should redirect_to admin_demo_rules_path(@demo.id)
    end

    it "should give a reasonable error with a long reply" do
      @params[:rule][:reply] = 'H' * 132
      post :create, @params
      response.status.should == 200 # should not redirect
      # Make sure @demo is set so that when you finally get it saved that it's still associated   
      # with the correct demo
      assigns[:demo].should_not be_nil
    end
  end

  describe "#update" do
    before(:each) do
      @rule = FactoryGirl.create :rule
      @params = {:id => @rule.id, 
                 :rule =>
                    {"primary_value"=>"yes, man",
                     "secondary_values"=>{"0"=>""},
                     "points"=>"3",
                     "reply"=>"Funky Chicken",
                     "description"=>"dee",
                     "alltime_limit"=>"",
                     "referral_points"=>"",
                     "suggestible"=>"1"}
                }
      clearance_signin_as_admin
      request.env["HTTP_REFERER"] = edit_admin_rule_path(@rule.id) # required so we can redirect :back
    end

    it "should update a rule" do
      put :update, @params
      response.should redirect_to admin_demo_rules_path(@rule.demo.id)
      @rule.reload.reply.should == "Funky Chicken"
    end

    it "should stay on the same page and not crash when you attempt to set a reply that is too long (which requires a call to 'flash_now_keep_primary_secondary_flashes') but when no secondary values passed in (because it just doesn't happen to have any)" do
      @params[:rule][:reply] = 'H' * 132
      deleted = @params[:rule].delete('secondary_values')
      deleted.should_not be_nil
      # Make damn sure there are no secondary values passed in, either as a 
      # string or as a symbol
      @params[:rule][:secondary_values].should be_nil
      @params[:rule]['secondary_values'].should be_nil
      put :update, @params
      response.status.should == 200
      # Make sure @demo is set so that when you finally get it saved that it's still associated   
      # with the correct demo
      assigns[:demo].should_not be_nil
    end


  end
end
