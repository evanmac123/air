require 'spec_helper'

#metal_testing_hack(EmailCommandController)

describe EmailCommandController do
  describe "#create" do
    before(:each) do
      ActionMailer::Base.deliveries.clear
      @user = FactoryGirl.create :user_with_phone

      @test_params = {
         "to"=>"email_commands@hengage.net",
         "from"=>@user.email,
         "subject"=>"I did something good!"
       }

      @test_command = "\n\nhere's the command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"

    end

    context "when properly posting an email" do
      it "should return 'success' with a 200 status" do
        params = @test_params.merge({:plain => @test_command})
        post 'create', params
        response.status.should eql 200
        response.body.should_not be_blank
        response.body.should eql 'success'
        response.content_type.should eql 'text/plain'
      end
    end
  end
end
