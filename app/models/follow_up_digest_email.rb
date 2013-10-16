class FollowUpDigestEmail < ActiveRecord::Base
  serialize :tile_ids, Array

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
    # The 'day name' select-box control was disabled ('send followup' checkbox was not checked)
    # or they scheduled the follow-up to go out on the current day (which doesn't make sense)
    return 0 if (follow_up_day.nil? or follow_up_day == Date::DAYNAMES[Date.today.wday])

    day_to_send = Date::DAYNAMES.index(follow_up_day)
    today = Date.today.wday

    day_to_send > today ? day_to_send - today : 7 - (today - day_to_send)
  end
end
