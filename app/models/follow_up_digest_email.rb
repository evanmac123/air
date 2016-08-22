class FollowUpDigestEmail < ActiveRecord::Base
  serialize :tile_ids, Array
  serialize :user_ids_to_deliver_to, Array

  belongs_to :demo

  DEFAULT_FOLLOW_UP = {'Sunday'    => 'Wednesday',
                       'Monday'    => 'Thursday',
                       'Tuesday'   => 'Friday',
                       'Wednesday' => 'Friday',
                       'Thursday'  => 'Monday',
                       'Friday'    => 'Tuesday',
                       'Saturday'  => 'Wednesday'}

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


  def trigger_deliveries
    recipients.each do |recipient_id| 
      TilesDigestMailer.delay.
        notify_one( demo.id, recipient_id, tile_ids, subject, true, headline, nil)
    end
  end

  def users_to_reject

    demos = Demo.arel_table
    board_memberships = BoardMembership.arel_table
    tile_completions = TileCompletion.arel_table


   res = BoardMembership.select(board_memberships[:user_id]).where(
     demos[:id].eq(demo.id).and(board_memberships[:followup_muted].eq('f'))
    ).joins(
      board_memberships
      .join(demos)
      .on(board_memberships[:demo_id].eq(demos[:id]))
      .join(tile_completions)
      .on(tile_completions[:user_id].eq(board_memberships[:user_id])).join_sources
    ).group(board_memberships[:user_id])
      .having(tile_completions[:user_id].count.gt(0))

    res.map(&:user_id)
  end

  def recipients
    user_ids_to_deliver_to - users_to_reject
  end

  private

  def headline
    original_digest_headline
  end

  def subject
    "Don't Miss#{original_digest_subject && original_digest_subject.prepend(': ') || ' Your New Tiles'}"
  end


end
