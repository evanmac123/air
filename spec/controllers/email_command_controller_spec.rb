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

    context "when properly posting an email with something that doesn't look like an autoresponse" do
      before do
        EmailCommand.any_instance.stubs(:looks_like_autoresponder?).returns(false)
        params = @test_params.merge({:plain => @test_command})
        post 'create', params
      end

      it "should return 'success' with a 200 status" do
        response.status.should eql 200
        response.body.should_not be_blank
        response.body.should eql 'success'
        response.content_type.should eql 'text/plain'
      end

      context "the reply" do
        it "should have an appropriate non-monitored-email response, referring them to support" do
          crank_dj_clear
          open_email(@user.email)
          current_email.to_s.should include("Sorry, you've replied to an unmonitored account. For assistance please contact support@air.bo.")
        end

        it "should reply-to set to support" do
          crank_dj_clear
          open_email(@user.email)
          current_email.reply_to.should == %w(support@air.bo)
        end

        it "should have the correct from address" do
          fancy_email = "Foo Inc. <foo@ourairbo.com>"
          Demo.any_instance.stubs(:reply_email_address).returns(fancy_email)

          crank_dj_clear
          open_email(@user.email)

          current_email.to_s.should include(%!From: "Foo Inc." <foo@ourairbo.com>!)
          current_email.from.should == %w(foo@ourairbo.com)
        end

        it "should have a good default from address when the email is not from a user we recognize" do
          EmailCommand.last.update_attributes(user_id: nil)
          crank_dj_clear
          open_email(@user.email)

          current_email.to_s.should include(%!From: Airbo <play@ourairbo.com>!)
          current_email.from.should == %w(play@ourairbo.com)
        end
      end
    end
  end
end
