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
end
