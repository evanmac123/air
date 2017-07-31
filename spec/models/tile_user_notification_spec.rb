require 'rails_helper'

RSpec.describe TileUserNotification, :type => :model do
  it { is_expected.to belong_to(:tile) }
  it { is_expected.to belong_to(:creator) }
  it { is_expected.to validate_presence_of(:tile) }
  it { is_expected.to validate_presence_of(:creator) }
  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:message) }

  describe ".options_for_scope_cd" do
    it "returns the correct options for cope selection" do
      expect(TileUserNotification.options_for_scope_cd).to eq([["answered", 0], ["did not answer", 1]])
    end
  end

  describe ".scopes" do
    it "returns the correct scopes defined as enums" do
      expect(TileUserNotification.scopes).to eq({ answered: 0, did_not_answer: 1 })
    end
  end

  describe ".options_for_answers" do
    let(:tile_with_answers) { OpenStruct.new(question_type: Tile::SURVEY, multiple_choice_answers: ["a", "b"]) }
    let(:tile_without_answers) { OpenStruct.new(multiple_choice_answers: ["a"]) }

    it "returns base option and multiple choice options when there is more than one answer" do
      expect(TileUserNotification.options_for_answers(tile: tile_with_answers)).to eq([[TileUserNotification::BASE_ANSWER_OPTION, nil], "a", "b"])
    end

    it "returns base option alone when there is one answer" do
      expect(TileUserNotification.options_for_answers(tile: tile_without_answers)).to eq([[TileUserNotification::BASE_ANSWER_OPTION, nil]])
    end
  end

  let(:user) { FactoryGirl.create(:client_admin) }
  let(:tile) { FactoryGirl.create(:tile) }

  describe "#before_save" do
    it "calls #normalize_blank_values" do
      tile_user_notification = TileUserNotification.new(tile: tile, creator: user, subject: "subject", message: "message")

      tile_user_notification.expects(:normalize_blank_values).once

      tile_user_notification.save
    end
  end

  describe "#users" do
    it "asks TileUserTargeter to get_users" do
      tile_user_notification = TileUserNotification.new(tile: tile, creator: user)

      tile_user_targeter_args = { tile: tile, rule: tile_user_notification.send(:get_targeter_rule) }

      tile_user_targeter = TileUserTargeter.new(tile_user_targeter_args)

      TileUserTargeter.expects(:new).with(tile_user_targeter_args).returns(tile_user_targeter)

      tile_user_targeter.expects(:get_users).once

      tile_user_notification.users
    end
  end

  describe "#user_count" do
    it "counts the users" do
      tile_user_notification = TileUserNotification.new(tile: tile, creator: user)

      tile_user_notification.expects(:users).returns(OpenStruct.new(count: 100))

      expect(tile_user_notification.user_count).to eq(100)
    end
  end

  describe "#deliver_notifications" do
    it "asks TileUserNotificationMailer to notify_all and updates recipient_count and delayed_job_id" do
      tile_user_notification = TileUserNotification.new(tile: tile, creator: user)
      tile_user_notification.expects(:user_count).returns(5)

      TileUserNotificationMailer.expects(:delay).with(run_at: nil, queue: TileUserNotification::DELAYED_JOB_QUEUE).returns(TileUserNotificationMailer)

      TileUserNotificationMailer.expects(:notify_all).with(tile_user_notification: tile_user_notification).returns(OpenStruct.new(id: 1))

      tile_user_notification.deliver_notifications
      expect(tile_user_notification.recipient_count).to eq(5)
      expect(tile_user_notification.delayed_job_id).to eq(1)
    end
  end

  describe "#from_email" do
    it "returns tile.demo.reply_email_address" do
      tile_user_notification = TileUserNotification.new(tile: tile, creator: user)

      expect(tile_user_notification.from_email).to eq(tile.demo.reply_email_address)
    end
  end

  describe "#get_targeter_rule" do
    it "returns hash of scope and answer" do
      tile_user_notification = TileUserNotification.new(scope_cd: 0, answer: "hey")

      expect(tile_user_notification.send(:get_targeter_rule)).to eq({ scope: tile_user_notification.scope, answer: tile_user_notification.answer })
    end
  end
end
