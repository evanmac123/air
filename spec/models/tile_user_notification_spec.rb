require 'rails_helper'

RSpec.describe TileUserNotification, :type => :model do
  let(:user) { FactoryBot.create(:client_admin) }
  let(:tile) { FactoryBot.create(:tile) }

  it { is_expected.to belong_to(:tile) }
  it { is_expected.to belong_to(:creator) }
  it { is_expected.to validate_presence_of(:tile) }
  it { is_expected.to validate_presence_of(:creator) }
  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:message) }

  describe "#before_save" do
    it "calls #normalize_blank_values" do
      tile_user_notification = TileUserNotification.new(tile: tile, creator: user, subject: "subject", message: "message", scope_cd: 0)

      tile_user_notification.expects(:normalize_blank_values).once

      tile_user_notification.save
    end
  end

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
    let(:tile_with_answers) { OpenStruct.new(is_survey?: true, multiple_choice_answers: ["a", "b"]) }
    let(:survey_tile_without_answers) { OpenStruct.new(is_survey?: true, multiple_choice_answers: ["a"]) }
    let(:quiz_tile_with_answers) { OpenStruct.new(is_survey?: false, multiple_choice_answers: ["a", "b"]) }

    it "returns base option and multiple choice options when there is more than one answer and tile.is_survey?" do
      expect(TileUserNotification.options_for_answers(tile: tile_with_answers)).to eq([[TileUserNotification::BASE_ANSWER_OPTION, nil], ["a", 0], ["b", 1]])
    end

    it "returns base option alone when there is one answer" do
      expect(TileUserNotification.options_for_answers(tile: survey_tile_without_answers)).to eq([[TileUserNotification::BASE_ANSWER_OPTION, nil]])
    end

    it "returns base option alone when tile is a quiz (!tile.is_survey?) even though there are multiple answers" do
      expect(TileUserNotification.options_for_answers(tile: quiz_tile_with_answers)).to eq([[TileUserNotification::BASE_ANSWER_OPTION, nil]])
    end
  end

  describe ".default_recipient_count" do
    it "asks a new instance of TileUserNotification to return its user_count" do
      mock_notification = OpenStruct.new(user_count: 5)
      TileUserNotification.expects(:new).with({
        tile: tile,
        scope_cd: TileUserNotification.scopes[:answered]
      }).returns(mock_notification)

      expect(TileUserNotification.default_recipient_count(tile: tile)).to eq(5)
    end
  end

  describe "#message_has_non_html_text" do
    it "raises an error if the message is just html tags (i.e. empty quill editor)" do
      tile_user_notification = TileUserNotification.new(tile: tile, creator: user, subject: "subject", message: "<p><br></p>", scope_cd: 0)

      expect(tile_user_notification.save).to be(false)
      expect(tile_user_notification.errors.full_messages).to eq(["Message can't be blank"])
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

      TileUserNotificationBulkMailJob.expects(:perform_later).with(tile_user_notification: tile_user_notification).returns(OpenStruct.new(id: 1))

      tile_user_notification.deliver_notifications
      expect(tile_user_notification.recipient_count).to eq(5)
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
      tile_user_notification = TileUserNotification.new(scope_cd: 0, answer_idx: 0)

      expect(tile_user_notification.send(:get_targeter_rule)).to eq({ scope: tile_user_notification.scope, answer_idx: 0 })
    end
  end

  describe "#deliver_test_notification" do
    it "asks TileUserNotificationMailer to notify_one to the given user" do
      tile_user_notification = TileUserNotification.new
      mock_mail_object = mock("Mail::Message")

      TileUserNotificationMailer.expects(:notify_one).with({
        user: user,
        tile_user_notification: tile_user_notification
      }).returns(mock_mail_object)

      mock_mail_object.expects(:deliver_now)

      tile_user_notification.deliver_test_notification(user: user)
    end
  end

  describe "#answer" do
    it "returns the string answer based on the answer_idx" do
      survey_tile = FactoryBot.build(:multiple_choice_tile, multiple_choice_answers: ["a", "b", "c"])
      tile_user_notification = TileUserNotification.new(answer_idx: 1, tile: survey_tile)

      expect(tile_user_notification.answer).to eq("b")
    end

    it "returns BASE_ANSWER_OPTION when answer_idx is nil" do
      survey_tile = FactoryBot.build(:multiple_choice_tile, multiple_choice_answers: ["a", "b", "c"])
      tile_user_notification = TileUserNotification.new(answer_idx: nil, tile: survey_tile)

      expect(tile_user_notification.answer).to eq(TileUserNotification::BASE_ANSWER_OPTION)
    end
  end

  describe "#demo" do
    it "returns its tile's demo" do
      tile_user_notification = TileUserNotification.new(tile: tile)

      expect(tile_user_notification.demo).to eq(tile.demo)
    end
  end

  describe "#decorate_for_tile_stats_table" do
    it "adds 'answer' and 'scope' ui helper attributes to the base attibutes" do
      survey_tile = FactoryBot.build(:multiple_choice_tile, multiple_choice_answers: ["a", "b", "c"])
      tile_user_notification = TileUserNotification.new(scope_cd: 1, answer_idx: 2, tile: survey_tile, creator: user)

      mock_attributes_hash = {}

      tile_user_notification.expects(:attributes).returns(mock_attributes_hash)
      mock_attributes_hash.expects(:merge).with({
        answer: tile_user_notification.answer,
        scope: tile_user_notification.decorated_scope
      })

      tile_user_notification.decorate_for_tile_stats_table
    end
  end

  describe "#decorated_scope" do
    it "returns the scope without underscores" do
      tile_user_notification = TileUserNotification.new(scope_cd: TileUserNotification.scopes[:did_not_answer])

      expect(tile_user_notification.decorated_scope).to eq("did not answer")
    end
  end

  describe "#interpolated_message" do
    it "asks UserInterpolateService to interpolate the message with the given user" do
      tile_user_notification = TileUserNotification.new(message: "Hey {{name}}")

      mock_user_interpolate_service = mock("UserInterpolateService")

      UserInterpolateService.expects(:new).with({ string: tile_user_notification.message, user: user }).returns(mock_user_interpolate_service)

      mock_user_interpolate_service.expects(:interpolate).once

      tile_user_notification.interpolated_message(user: user)
    end
  end
end
