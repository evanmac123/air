require 'spec_helper'

#metal_testing_hack(EmailCommandController)

describe EmailCommandController do
  describe "#create" do
    before(:each) do
      ActionMailer::Base.deliveries.clear
      @user = Factory :user_with_phone

      @test_params = {
         "to"=>"email_commands@hengage.net",
         "from"=>@user.email,
         "subject"=>"I did something good!"
       }

      @test_command = "\n\nhere's the command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"

    end

    context "when properly posting an email" do
      before(:each) do
      end

      it "should return 'success' with a 200 status" do
        params = @test_params.merge({:plain => @test_command})
        post 'create', params
        response.status.should eql 200
        response.body.should_not be_blank
        response.body.should eql 'success'
        response.content_type.should eql 'text/plain'
      end

      it "should record a EmailCommand" do
        params = @test_params.merge({:plain => @test_command})
        post 'create', params
        EmailCommand.count.should eql 1
        email_command = EmailCommand.first
        email_command.email_from.should eql @user.email
        email_command.email_subject.should eql params['subject']
        email_command.status.should eql EmailCommand::Status::SUCCESS
        email_command.response.should eql "Sorry, I don't understand what that means. Email \"s\" to suggest we add what you sent."
      end

      it "should process 'myid' correctly" do
        params = @test_params.merge({:plain => "myid"})
        post 'create', params
        EmailCommand.count.should eql 1
        email_command = EmailCommand.first
        email_command.email_from.should eql @user.email
        email_command.email_subject.should eql params['subject']
        email_command.status.should eql EmailCommand::Status::SUCCESS
        email_command.response.should eql "Your username is #{@user.sms_slug}."
      end

      it "should process 'moreinfo' correctly" do
        params = @test_params.merge({:plain => "moreinfo"})
        post 'create', params
        EmailCommand.count.should eql 1
        email_command = EmailCommand.first
        email_command.email_from.should eql @user.email
        email_command.email_subject.should eql params['subject']
        email_command.status.should eql EmailCommand::Status::SUCCESS
        email_command.response.should eql "Great, we'll be in touch. Stay healthy!"
      end

      it "should process 'more' correctly" do
        params = @test_params.merge({:plain => "more"})
        post 'create', params
        EmailCommand.count.should eql 1
        email_command = EmailCommand.first
        email_command.email_from.should eql @user.email
        email_command.email_subject.should eql params['subject']
        email_command.status.should eql EmailCommand::Status::SUCCESS
        email_command.response.should eql "Great, we'll be in touch. Stay healthy!"
      end

      it "should process 's' correctly" do
        params = @test_params.merge({:plain => "s ate kitten"})
        post 'create', params
        EmailCommand.count.should eql 1
        email_command = EmailCommand.first
        email_command.email_from.should eql @user.email
        email_command.email_subject.should eql params['subject']
        email_command.status.should eql EmailCommand::Status::SUCCESS
        # make sure the suggestion was recorded
        Suggestion.first.value.should eql "ate kitten"
        email_command.response.should eql "Thanks! We'll take your suggestion into consideration."
      end

      it "should process 'suggest' correctly" do
        params = @test_params.merge({:plain => "suggest ate kitten"})
        post 'create', params
        EmailCommand.count.should eql 1
        email_command = EmailCommand.first
        email_command.email_from.should eql @user.email
        email_command.email_subject.should eql params['subject']
        email_command.status.should eql EmailCommand::Status::SUCCESS
        # make sure the suggestion was recorded
        Suggestion.first.value.should eql "ate kitten"
        email_command.response.should eql "Thanks! We'll take your suggestion into consideration."
      end

      it "should process 'lastquestion' correctly" do
        params = @test_params.merge({:plain => "lastquestion"})
        post 'create', params
        EmailCommand.count.should eql 1
        email_command = EmailCommand.first
        email_command.email_from.should eql @user.email
        email_command.email_subject.should eql params['subject']
        email_command.status.should eql EmailCommand::Status::SUCCESS
        email_command.response.should eql "You're not currently taking a survey"
      end

      it "should process 'survey' correctly" do
        params = @test_params.merge({:plain => "survey"})
        post 'create', params
        EmailCommand.count.should eql 1
        email_command = EmailCommand.first
        email_command.email_from.should eql @user.email
        email_command.email_subject.should eql params['subject']
        email_command.status.should eql EmailCommand::Status::SUCCESS
        email_command.response.should eql "Sorry, there is not currently a survey open."
      end
    end
  end
end


=begin
May want to test these additional special commands.

# create a user, have another user try to follow them.
'follow', 'connect'
  self.follow(user, args.first)
/^\d+$/
  self.respond_to_survey(user, command_name)
/^[a-z]$/
  self.use_suggested_item(user, command_name)
'accept'
  self.accept_follower(user, args.first)
'ignore'
  self.ignore_follow_request(user, args.first)
=end
