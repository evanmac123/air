class FollowUpDigestEmail < ActiveRecord::Base
  serialize :user_ids_to_deliver_to, Array
  belongs_to :tiles_digest

  before_validation :set_subjects, on: :create

  validates_presence_of :subject

  DEFAULT_FOLLOW_UP = {'Sunday'    => 'Wednesday',
                       'Monday'    => 'Thursday',
                       'Tuesday'   => 'Friday',
                       'Wednesday' => 'Friday',
                       'Thursday'  => 'Monday',
                       'Friday'    => 'Tuesday',
                       'Saturday'  => 'Wednesday'}

  scope :scheduled, -> { where(sent: false).order("send_on ASC") }

  def self.send_follow_up_digest_email
    scheduled.where(send_on: Date.today)
  end

  def self.follow_up_days(follow_up_day)
    return 0 if follow_up_day == 'Never'

    # 'DAYNAMES' is a Ruby array of ['Sunday', 'Monday', ..., 'Saturday']
    # 'wday' is a Ruby method which returns an integer day-of-the-week: Sunday = 0, Monday = 1, ..., Saturday = 6
    today = Date.today.wday
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
    recipients.each_with_index do |recipient_id, index|
      TilesDigestMailer.delay.notify_one(tiles_digest, recipient_id, resolve_subject(index: index), TilesDigestMailFollowUpPresenter)
    end

    post_process_delivery
  end

  def post_process_delivery
    schedule_digest_sent_ping
    self.update_attributes(sent: true, user_ids_to_deliver_to: nil)
    tiles_digest.update_attributes(followup_delivered: true)
  end

  def users_to_reject
    demos = Demo.arel_table
    board_memberships = BoardMembership.arel_table
    tile_completions = TileCompletion.arel_table

    res = BoardMembership.select([:user_id, :followup_muted, tile_completions[:user_id].count]).where(
      demos[:id].eq(demo.id))
      .joins(board_memberships
      .join(demos)
      .on(board_memberships[:demo_id].eq(demos[:id]))
      .join(tile_completions, Arel::Nodes::OuterJoin)
      .on(board_memberships[:user_id].eq(tile_completions[:user_id])
      .and(tile_completions[:tile_id].in(tile_ids))
         ).join_sources)
      .group([board_memberships[:user_id], board_memberships[:followup_muted]])
      .having(tile_completions[:user_id].count.gt(0).or(board_memberships[:followup_muted].eq(true)))
    res.map(&:user_id)
  end

  def recipients
    user_ids_to_deliver_to - users_to_reject
  end

  def headline
    tiles_digest.headline
  end

  def tiles_digest_subject
    tiles_digest.subject
  end

  def tiles_digest_alt_subject
    tiles_digest.alt_subject
  end

  def resolve_subject(index:)
    return subject unless alt_subject.present?

    if index.even?
      alt_subject
    else
      subject
    end
  end

  def set_subjects
    self.subject = decorated_subject(plain_subject: tiles_digest_subject)

    if tiles_digest_alt_subject
      self.alt_subject = decorated_subject(plain_subject: tiles_digest_alt_subject)
    end
  end

  def decorated_subject(plain_subject:)
    "Don't Miss: #{plain_subject}"
  end

  def schedule_digest_sent_ping
    TrackEvent.ping(
      'FollowUpDigest - Sent',
      {
        tiles_digest_id: tiles_digest_id,
        subject: subject,
        alt_subject: alt_subject
      },
      tiles_digest.sender
    )
  end
end
