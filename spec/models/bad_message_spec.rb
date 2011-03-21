require 'spec_helper'

describe BadMessage do
  it { should validate_presence_of(:phone_number) }
  it { should validate_presence_of(:received_at) }

  context "on creation" do
    context "when there is a previously sent message from the same number on the watch list" do
      before(:each) do
        @phone_number = '+14155551212'
        old_message = Factory :bad_message, :phone_number => @phone_number
        old_message.on_watch_list = true
        old_message.save!
      end

      it "should put this message on the watch list" do
        (Factory :bad_message, :phone_number => @phone_number).on_watch_list.should be_true
      end
    end
  end
end
