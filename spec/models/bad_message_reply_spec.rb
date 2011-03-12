require 'spec_helper'

describe BadMessageReply do
  it { should validate_presence_of :bad_message_id }
  it "should make sure the body doesn't go over the maximum length" do
    reply = Factory :bad_message_reply
    reply.body = 'X' * 160
    reply.should be_valid
    reply.body = 'X' * 161
    reply.should_not be_valid
  end
end
