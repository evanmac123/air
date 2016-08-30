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
#
  end

  def recipients
    user_ids_to_deliver_to - users_to_reject
  end

  private

  def headline
    original_digest_headline
  end

  def subject
   "Don't Miss: #{original_digest_subject}"
  end

  #TODO Deprecate

  def trigger_deliveries_legacy

    user_ids_legacy.each    { |user_id| TilesDigestMailer.delay.notify_one(demo.id, user_id, tile_ids, subject, true, headline, nil) }

  end

  def user_ids_legacy

    ids = demo.users_for_digest(unclaimed_users_also_get_digest).where(id: user_ids_to_deliver_to).pluck(:id)
    ids.reject! { |user_id| TileCompletion.user_completed_any_tiles?(user_id, tile_ids)}
    ids.reject! { |user_id| BoardMembership.where(demo_id: demo_id, user_id: user_id, followup_muted: true).first.present? }
    ids
  end

end
