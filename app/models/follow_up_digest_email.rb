class FollowUpDigestEmail < ActiveRecord::Base
  serialize :user_ids_to_deliver_to, Array

  belongs_to :tiles_digest

  DEFAULT_FOLLOW_UP = {'Sunday'    => 'Wednesday',
                       'Monday'    => 'Thursday',
                       'Tuesday'   => 'Friday',
                       'Wednesday' => 'Friday',
                       'Thursday'  => 'Monday',
                       'Friday'    => 'Tuesday',
                       'Saturday'  => 'Wednesday'}

  before_create :set_subject

  def self.send_follow_up_digest_email
    where send_on: Date.today
  end

  def self.follow_up_days(follow_up_day)
    return 0 if follow_up_day == 'Never'

    # 'DAYNAMES' is a Ruby array of ['Sunday', 'Monday', ..., 'Saturday']
    # 'wday' is a Ruby method which returns an integer day-of-the-week: Sunday = 0, Monday = 1, ..., Saturday = 6
    today = Date.today.wday
    day_to_send = Date::DAYNAMES.index(follow_up_day)

    day_to_send > today ? day_to_send - today : 7 - (today - day_to_send)
  end

  def set_subject
    self.subject = tiles_digest.subject || "Your New Tiles"
  end

  def demo
    tiles_digest.demo
  end

  def tile_ids
    tiles_digest.tile_ids
  end

  def trigger_deliveries
    recipients.each do |recipient_id|
      TilesDigestMailer.delay.
        notify_one(tiles_digest.demo_id, recipient_id, tiles_digest.tile_ids, decorated_subject, true, headline, nil)
    end

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

  def decorated_subject
    "Don't Miss: #{subject}"
  end
end
