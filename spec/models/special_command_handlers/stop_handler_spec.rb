require 'spec_helper'

def invoke_handler
  handler = SpecialCommandHandlers::StopHandler.new(@user, @command_name, @args, @parsing_options, @return_message_type)
  handler.handle_command
end

describe SpecialCommandHandlers::StopHandler do
  before do
    @user = FactoryGirl.create(:user_with_phone, name: 'Juan')
    @user.notification_method.should == 'both'
    @command_name = 'stop'
    @args = []
    @parsing_options = {}
    @return_message_type = nil
  end

  it "should do nothing if stop received from email" do
    @parsing_options[:channel] = :email
    invoke_handler.should be_nil
    @user.reload.notification_method.should == 'both'
  end

  it "should set notification method to 'email' if 'stop' received from sms" do
    @parsing_options[:channel] = :sms
    expected = "Ok, you won't receive any more texts from us. To change your contact preferences, log into www.airbo.com and click Settings, or email support@airbo.com."

    invoke_handler.should == expected
    @user.reload.notification_method.should == 'email'
  end

end
