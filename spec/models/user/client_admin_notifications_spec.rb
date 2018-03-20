require 'spec_helper'

describe User do
  # User::ClientAdminNotifications

  let(:user) { FactoryBot.create(:user) }
  let(:demo_id) { user.demo_id }

  describe "#set_tile_email_report_notification" do
    it "continues to increment the redis key" do
      expect(user.redis[:client_admin_notifications][demo_id][:tile_email_report].call(:get)).to eq(nil)

      user.set_tile_email_report_notification(board_id: demo_id)

      expect(user.redis[:client_admin_notifications][demo_id][:tile_email_report].call(:get)).to eq("1")

      user.set_tile_email_report_notification(board_id: demo_id)

      expect(user.redis[:client_admin_notifications][demo_id][:tile_email_report].call(:get)).to eq("2")
    end
  end

  describe "#remove_tile_email_report_notification" do
    it "removes the redis key" do
      user.redis[:client_admin_notifications][demo_id][:tile_email_report].call(:set, "hello")

      expect(user.redis[:client_admin_notifications][demo_id][:tile_email_report].call(:get)).to eq("hello")

      user.remove_tile_email_report_notification

      expect(user.redis[:client_admin_notifications][demo_id][:tile_email_report].call(:get)).to eq(nil)
    end
  end

  describe "#get_tile_email_report_notification_content" do
    it "retrieves the keys content" do
      user.set_tile_email_report_notification(board_id: demo_id)

      expect(user.get_tile_email_report_notification_content).to eq("1")

      user.set_tile_email_report_notification(board_id: demo_id)

      expect(user.get_tile_email_report_notification_content).to eq("2")
    end
  end

  describe "has_tile_email_report_notification?" do
    it "returns true or false if the key is populated" do
      expect(user.has_tile_email_report_notification?).to eq(false)

      user.set_tile_email_report_notification(board_id: demo_id)

      expect(user.has_tile_email_report_notification?).to eq(true)
    end
  end

  describe "when a user gets notifications in different boards" do
    it "posts and removes notifications to the right boards" do
      demo_2 = FactoryBot.create(:demo, name: "Demo 2")
      _board_membership_2 = BoardMembership.create(user: user, demo: demo_2, is_current: false)

      3.times do
        user.set_tile_email_report_notification(board_id: demo_id)
      end

      5.times do
        user.set_tile_email_report_notification(board_id: demo_2.id)
      end

      expect(user.get_tile_email_report_notification_content).to eq("3")

      user.remove_tile_email_report_notification

      expect(user.get_tile_email_report_notification_content).to eq(nil)
      expect(user.redis[:client_admin_notifications][demo_2.id][:tile_email_report].call(:get)).to eq("5")

      user.move_to_new_demo(demo_2)
      user.reload

      expect(user.get_tile_email_report_notification_content).to eq("5")
    end
  end
end
