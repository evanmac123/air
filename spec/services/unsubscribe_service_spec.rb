require 'spec_helper'

describe UnsubscribeService do
  describe ".unsubscribe" do
    describe "when email_type is default" do
      it "updates relevant board_membership notification_pref to unsubscribe" do
        build_data_for_email_type("default")
        @unsubscribe_service.unsubscribe

        expect(@unsubscribe_service.user.board_memberships.first.notification_pref).to eq(:unsubscribe)
      end
    end

    describe "when email_type is explore" do
      it "updates user record to not receive explore emails" do
        build_data_for_email_type("explore")
        @unsubscribe_service.unsubscribe

        expect(@unsubscribe_service.user.receives_explore_email).to eq(false)
      end
    end

    describe "when email_type is activity" do
      it "updates relevant board_membership to not receive weekly actiivty reports" do
        build_data_for_email_type("activity")
        @unsubscribe_service.unsubscribe

        expect(@unsubscribe_service.user.board_memberships.first.send_weekly_activity_report).to eq(false)
      end
    end
  end

  def build_data_for_email_type(email_type)
    user = FactoryBot.create(:user)
    @unsubscribe_service = UnsubscribeService.new({
      user_id: user.id,
      demo_id: user.demo.id,
      email_type: email_type,
      token: "123"
    })
  end
end
