require 'spec_helper'

def invoke_handler
  handler = SpecialCommandHandlers::StopHandler.new(@user, @command_name, @args, @parsing_options, @return_message_type)
  handler.handle_command
end

describe SpecialCommandHandlers::StopHandler do
  before do
    @user = FactoryGirl.create(:user_with_phone, name: 'Juan')
    expect(@user.notification_method).to eq('both')
    @command_name = 'stop'
    @args = []
    @parsing_options = {}
    @return_message_type = nil
  end

  it "should do nothing if stop received from email" do
    @parsing_options[:channel] = :email
    expect(invoke_handler).to be_nil
    expect(@user.reload.notification_method).to eq('both')
  end

  it "should set notification method to 'email' if 'stop' received from sms" do
    @parsing_options[:channel] = :sms
    expected = "Ok, you won't receive any more texts from us. To change your contact preferences, log into www.airbo.com and click Settings, or email support@airbo.com."

    expect(invoke_handler).to eq(expected)
    expect(@user.reload.notification_method).to eq('email')
  end

end
