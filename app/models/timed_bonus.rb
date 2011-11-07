# Bonus activated (once only) if user acts by a certain expiration time.

class TimedBonus < ActiveRecord::Base
  belongs_to :demo
  belongs_to :user

  validates_presence_of :expires_at, :points, :user_id, :demo_id

  def self.fulfillable_by(user)
    where("fulfilled IS DISTINCT FROM true AND expires_at > ? AND user_id = ? AND demo_id = ?", Time.now, user.id, user.demo_id)
  end

  def sms_response
    uninterpolated_response = sms_text.present? ? sms_text : "You acted before the time limit expired! +%{points} points."

    I18n.interpolate(uninterpolated_response, :points => points)
  end
end
