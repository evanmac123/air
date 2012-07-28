require 'spec_helper'
include SteakHelperMethods

describe Admin::GoalsController do
  describe "#create" do
    context "the rules assigned have short replies" do
      it "should save the goal and set the rules' goal_id" do
        clearance_signin_as_admin
        @demo = FactoryGirl.create(:demo)
        @rule1 = FactoryGirl.create(:rule, reply: 'A short sentence')
        @rule2 = FactoryGirl.create(:rule, reply: 'Another short sentence')
        @params = {"goal" => {"name"=>"naaaaame",
                              "achievement_text"=>"accccc",
                              "completion_sms_text"=>"commmmmm",
                              "rule_ids"=>[@rule1.id, @rule2.id]},
                   "demo_id" => @demo.id
                   }
        post :create, @params
        @rule1.reload.goal.should_not be_nil
      end
    end
    
    context "the rules assigned have long (> 100 chars) replies" do
      it "should save the goal and set the rules' goal_id" do
        clearance_signin_as_admin
        @demo = FactoryGirl.create(:demo)
        @rule1 = FactoryGirl.create(:rule, description: 'yes!', reply: 'B' * 120)
        @rule2 = FactoryGirl.create(:rule, description: 'no!', reply: 'C' * 115)
        @params = {"goal" => {"name"=>"naaaaame",
                              "achievement_text"=>"accccc",
                              "completion_sms_text"=>"commmmmm",
                              "rule_ids"=>[@rule1.id, @rule2.id]},
                   "demo_id" => @demo.id
                   }
        post :create, @params
        # The rule should not have a goal_id
        @rule1.reload.goal.should be_nil
        
        # The goal should not be saved
        Goal.first.should be_nil

        # Should render :new without redirect
        response.status.should == 200 #redirect_to(new_admin_demo_goal_path(@demo))
        flash[:failure].to_s.should include('Please shorten')
      end
    end
  end
end
