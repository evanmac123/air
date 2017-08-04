class TileUserNotification < ActiveRecord::Base
  include NormalizeBlankValues
  before_save :normalize_blank_values

  belongs_to :tile
  belongs_to :creator, class_name: "User"
  validates_presence_of :tile
  validates_presence_of :creator
  validates_presence_of :subject
  validates_presence_of :message

  as_enum :scope, answered: 0, did_not_answer: 1

  DELAYED_JOB_QUEUE = "TileUserNotifications"
  BASE_ANSWER_OPTION = "the Tile"

  #temporary roolout strategy
  def self.launched?
    false
  end

  def self.options_for_scope_cd
    [["answered", 0], ["did not answer", 1]]
  end

  def self.options_for_answers(tile:)
    base_option = [BASE_ANSWER_OPTION, nil]
    if tile.question_type == Tile::SURVEY && tile.multiple_choice_answers.length > 1
      answers = tile.multiple_choice_answers.dup
      answers.unshift(base_option)
    else
      [base_option]
    end
  end

  def users
    @_users ||= TileUserTargeter.new(tile: tile, rule: get_targeter_rule).get_users
  end

  def user_count
    users.count
  end

  def deliver_notifications
    delayed_job = TileUserNotificationMailer.delay(run_at: send_at, queue: DELAYED_JOB_QUEUE).notify_all(tile_user_notification: self)

    self.update_attributes(recipient_count: user_count, delayed_job_id: delayed_job.id)
  end

  def from_email
    tile.demo.reply_email_address
  end

  private

    def get_targeter_rule
      { scope: scope, answer: answer }
    end
end
