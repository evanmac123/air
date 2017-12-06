class FollowUpDigestEmail < ActiveRecord::Base
  belongs_to :tiles_digest

  DEFAULT_FOLLOW_UP = {'Sunday'    => 'Wednesday',
                       'Monday'    => 'Thursday',
                       'Tuesday'   => 'Friday',
                       'Wednesday' => 'Friday',
                       'Thursday'  => 'Monday',
                       'Friday'    => 'Tuesday',
                       'Saturday'  => 'Wednesday'}

  scope :scheduled, -> { where(sent: false).order("send_on ASC") }

  def self.send_follow_up_digest_email
    scheduled.where(send_on: Date.current)
  end

  def self.follow_up_days(follow_up_day)
    return 0 if follow_up_day == 'Never'
    today = Date.current.wday
    day_to_send = Date::DAYNAMES.index(follow_up_day)

    day_to_send > today ? day_to_send - today : 7 - (today - day_to_send)
  end

  def demo
    tiles_digest.demo
  end

  def tile_ids
    tiles_digest.tile_ids_for_email
  end

  def trigger_deliveries
    set_subject
    recipient_ids.each do |recipient_id|
      TilesDigestMailer.delay.notify_one(tiles_digest, recipient_id, subject, TilesDigestMailFollowUpPresenter)
    end

    post_process_delivery
  end

  def post_process_delivery
    schedule_digest_sent_ping
    self.update_attributes(sent: true)
    tiles_digest.update_attributes(followup_delivered: true)
  end

  def users_to_reject
    tiles_digest.users.joins(:tile_completions).where(tile_completions: { tile_id: tile_ids }).pluck(:id)
  end

  def recipients
    if users_to_reject.present?
      users.where("users.id NOT IN (?)", users_to_reject)
    else
      users
    end
  end

  def users
    tiles_digest.users.joins(:board_memberships)
  end

  def recipient_ids
    recipients.pluck(:id)
  end

  def decorated_subject(plain_subject)
    "Don't Miss: #{plain_subject}"
  end

  def subject_before_sent
    if subject.present?
      subject
    else
      decorated_subject(tiles_digest.highest_performing_subject_line)
    end
  end

  def set_subject
    unless subject.present?
      self.update_attributes(subject: subject_before_sent)
    end
  end

  def schedule_digest_sent_ping
    TrackEvent.ping(
      'FollowUpDigest - Sent',
      {
        tiles_digest_id: tiles_digest_id,
        subject: subject
      },
      tiles_digest.sender
    )
  end
end
