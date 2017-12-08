class UnsubscribeService
  attr_reader :user_id, :demo_id, :email_type, :token

  def initialize(attrs)
    @user_id = attrs[:user_id]
    @demo_id = attrs[:demo_id]
    @email_type = attrs[:email_type]
    @token = attrs[:token]
  end

  def user
    @_user ||= User.where(id: user_id).first
  end

  def valid_unsubscribe?
    EmailLink.validate_token(user, token)
  end

  def unsubscribe
    case email_type
    when "activity"
      unsubscribe_activity
    when "explore"
      unsubscribe_explore
    else
      unsubscribe_default
    end
  end

  def copy_for_new_unsubscribe
    case email_type
    when "activity"
      "You will no longer receives weekly activity emails from Airbo."
    when "explore"
      "You will no longer receive Explore emails from Airbo."
    else
      "You may miss important updates about your benefits and other important programs from your employer."
    end
  end

  private

    def unsubscribe_activity
      bm = user.board_memberships.where(demo_id: demo_id).first

      if bm.present?
        bm.update_attributes(send_weekly_activity_report: false)
      end
    end

    def unsubscribe_explore
      user.update_attributes(receives_explore_email: false)
    end

    def unsubscribe_default
      bm = user.board_memberships.where(demo_id: demo_id).first

      if bm.present?
        bm.update_attributes(notification_pref_cd: BoardMembership.unsubscribe)
      end
    end
end
