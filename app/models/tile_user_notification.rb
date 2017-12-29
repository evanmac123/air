class TileUserNotification < ActiveRecord::Base
  include NormalizeBlankValues

  before_save :normalize_blank_values

  belongs_to :tile
  belongs_to :creator, class_name: "User"
  validates_presence_of :tile
  validates_presence_of :creator
  validates_presence_of :subject
  validates_presence_of :scope_cd
  validate :message_has_non_html_text

  as_enum :scope, answered: 0, did_not_answer: 1

  DELAYED_JOB_QUEUE = "TileUserNotifications"
  BASE_ANSWER_OPTION = "the Tile"

  def self.options_for_scope_cd
    [["answered", 0], ["did not answer", 1]]
  end

  def self.options_for_answers(tile:)
    base_option = [BASE_ANSWER_OPTION, nil]
    if tile.is_survey? && tile.multiple_choice_answers.length > 1
      answers = tile.multiple_choice_answers.dup
      anwers_witn_indices = answers.map.with_index { |answer, i| [answer, i] }
      anwers_witn_indices.unshift(base_option)
    else
      [base_option]
    end
  end

  def self.default_recipient_count(tile:)
    TileUserNotification.new(tile: tile, scope_cd: self.scopes[:answered]).user_count
  end

  def users
    @_users ||= TileUserTargeter.new(tile: tile, rule: get_targeter_rule).get_users
  end

  def user_count
    users.count(:id)
  end

  def deliver_notifications
    delayed_job = TileUserNotificationMailer.delay(queue: DELAYED_JOB_QUEUE).notify_all(tile_user_notification: self)

    self.update_attributes(recipient_count: user_count, delayed_job_id: delayed_job.id)
  end

  def deliver_test_notification(user:)
    TileUserNotificationMailer.notify_one(user: user, tile_user_notification: self).deliver_now
  end

  def from_email
    tile.demo.reply_email_address
  end

  def answer
    if answer_idx
      tile.multiple_choice_answers[answer_idx]
    else
      BASE_ANSWER_OPTION
    end
  end

  def demo
    tile.demo
  end

  def decorate_for_tile_stats_table
    attributes.merge({ answer: answer, scope: decorated_scope })
  end

  def decorated_scope
    scope.to_s.gsub("_", " ")
  end

  def interpolated_message(user:)
    UserInterpolateService.new(string: message, user: user).interpolate
  end

  private

    def get_targeter_rule
      { scope: scope, answer_idx: answer_idx }
    end

    def message_has_non_html_text
      raw_text = ActionController::Base.helpers.strip_tags(message)
      errors.add(:message, "can't be blank") unless raw_text.present?
    end
end
