require 'spec_helper'

describe BadMessageReply do
  it { is_expected.to validate_presence_of :bad_message_id }
  it "should make sure the body doesn't go over the maximum length" do
    reply = FactoryGirl.create :bad_message_reply
    reply.body = 'X' * 160
    expect(reply).to be_valid
    reply.body = 'X' * 161
    expect(reply).not_to be_valid
  end
end
