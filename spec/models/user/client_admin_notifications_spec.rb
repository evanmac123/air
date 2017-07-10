require 'spec_helper'

describe User do
  # User::ClientAdminNotifications

  let(:user) { FactoryGirl.create(:user) }

  describe "#set_tile_email_report_notification" do
    it "continues to increment the redis key" do
      expect(user.rdb[:client_admin_notifications][:tile_email_report].get).to eq(nil)

      user.set_tile_email_report_notification

      expect(user.rdb[:client_admin_notifications][:tile_email_report].get).to eq("1")

      user.set_tile_email_report_notification

      expect(user.rdb[:client_admin_notifications][:tile_email_report].get).to eq("2")
    end
  end

  describe "#remove_tile_email_report_notification" do
    it "removes the redis key" do
      user.rdb[:client_admin_notifications][:tile_email_report].set("hello")

      expect(user.rdb[:client_admin_notifications][:tile_email_report].get).to eq("hello")

      user.remove_tile_email_report_notification

      expect(user.rdb[:client_admin_notifications][:tile_email_report].get).to eq(nil)
    end
  end

  describe "#get_tile_email_report_notification_content" do
    it "retrieves the keys content" do
      user.set_tile_email_report_notification

      expect(user.get_tile_email_report_notification_content).to eq("1")

      user.set_tile_email_report_notification

      expect(user.get_tile_email_report_notification_content).to eq("2")
    end
  end

  describe "has_tile_email_report_notification?" do
    it "returns true or false if the key is populated" do
      expect(user.has_tile_email_report_notification?).to eq(false)

      user.set_tile_email_report_notification

      expect(user.has_tile_email_report_notification?).to eq(true)
    end
  end
end
