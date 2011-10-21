require 'spec_helper'

metal_testing_hack(EmailCommandController)

describe EmailCommandController do
  describe "#create" do
    before(:each) do
      # We don't use hardly any of these fields, but this is what Twilio 
      # sends.

      @user = Factory :user

      @params = {
         "to"=>"email_commands@hengage.net",
         "from"=>@user.email,
         "subject"=>"I did something good!",
         "plain"=>"\n\nhere's the command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
       }

    end

    context "when properly posting an email" do
      before(:each) do
        post 'create', @params
      end

      it "should return some text with a 200 status" do
        response.status.should eql 200
        response.content_type.should eql 'text/plain'
        response.body.should_not be_blank
      end

      it "should record a EmailCommand" do
        EmailCommand.count.should eql 1
        email_command = EmailCommand.first
        email_command.email_from.should eql @user.email
        email_command.email_subject.should eql @params['subject']
        email_command.status.should eql EmailCommand::Status::VERIFIED_USER
      end
    end

  end
end
