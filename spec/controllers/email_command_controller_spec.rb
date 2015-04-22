require 'spec_helper'

#metal_testing_hack(EmailCommandController)

describe EmailCommandController do
  describe "#create" do
    before(:each) do
      ActionMailer::Base.deliveries.clear
      @user = FactoryGirl.create :user_with_phone

      @test_params = {
         "to"      => "email_commands@hengage.net",
         "from"    => @user.email,
         "subject" => "I did something good!",
         "plain"   => "this isn't even hooked up anymore to speak of"
       }

      @test_command = "\n\nhere's the command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
    end

    shared_examples_for "a success with a reply going back" do
      it "should return 'success' with a 200 status" do
        response.status.should eql 200
        response.body.should_not be_blank
        response.body.should eql 'success'
        response.content_type.should eql 'text/plain'
      end
    end

    shared_examples_for "a silent success" do
      it "should return a blank response with a 201 status, indicating we have no reply to send to the user" do
        response.status.should eql 201
        response.body.should be_blank
        response.content_type.should eq 'text/plain'
      end
    end

    context "when properly posting an email with something that doesn't look like an autoresponse" do
      before do
        EmailCommand.any_instance.stubs(:looks_like_autoresponder?).returns(false)
      end

      context "if the user in question hasn't gotten an unmonitored-mailbox response ever before" do
        before do
          post 'create', @test_params
        end

        it_should_behave_like "a success with a reply going back"
      end

      context "if the user in question has gotten an unmonitored-mailbox response at some point in the past, but not within the threshold" do
        before do
          Timecop.freeze
          @user.last_unmonitored_mailbox_response_at = 3601.seconds.ago
          @user.save!
          post 'create', @test_params
        end

        after do
          Timecop.return
        end

        it_should_behave_like "a success with a reply going back"
        
        it "should leave the timestamp updated" do
          # the ridiculous things we have to do to deal with times in Ruby...
          (Time.now - @user.reload.last_unmonitored_mailbox_response_at).to_i.should == 0
        end
      end

      context "if the user in question has gotten an unmonitored-mailbox response within the threshold" do
        before do
          Timecop.freeze
          @user.last_unmonitored_mailbox_response_at = 3599.seconds.ago
          @user.save!
          post 'create', @test_params
        end

        it_should_behave_like "a silent success"
      end

      context "the reply" do
        before do
          post 'create', @test_params
        end

        it "should have an appropriate non-monitored-email response, referring them to support" do
          crank_dj_clear
          open_email(@user.email)
          current_email.to_s.should include("Sorry, you've replied to an unmonitored account. For assistance please contact support@airbo.com.")
        end

        it "should reply-to set to support" do
          crank_dj_clear
          open_email(@user.email)
          current_email.reply_to.should == %w(support@airbo.com)
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

    context "when it looks like we have an autoresponder" do
      before do
        EmailCommand.any_instance.stubs(:looks_like_autoresponder?).returns(true)
        post 'create', @test_params
      end

      it_should_behave_like "a silent success"
    end
  end
end
