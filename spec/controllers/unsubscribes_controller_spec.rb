require 'spec_helper'

describe UnsubscribesController do
  describe "POST create" do
    it "unsubscribes user and sends ping" do
      user = FactoryBot.create(:user)

      subject.expects(:ping).with('Unsubscribed', { email_type: 'default' }, user)
      UnsubscribeService.any_instance.expects(:valid_unsubscribe?).returns(true)
      UnsubscribeService.any_instance.expects(:unsubscribe)

      post(:create, { user_id: user.id, demo_id: user.demo.id, email_type: 'default', token: '123' })

      expect(flash[:success].present?).to eq(true)
    end

    it "returns a flash if invalid unsubscribe" do
      user = FactoryBot.create(:user)
      UnsubscribeService.any_instance.expects(:valid_unsubscribe?).returns(false)

      post(:create, { user_id: user.id, demo_id: user.demo.id, email_type: 'default', token: '123' })

      expect(flash[:failure].present?).to eq(true)
    end
  end
end
