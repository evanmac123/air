class UnsubscribesController < ApplicationController
  def new
    @user_id = params[:user_id]
    @demo_id = params[:demo_id]
    @email_type = params[:email_type]
    @token = params[:token]
    @copy = copy_for_new_unsubscribe(@email_type)

    render layout: 'external'
  end

  def create
    @user = User.find(params[:user_id])
    if EmailLink.validate_token(@user, params[:token])
      sign_in(@user, :remember_user) if @user.end_user_in_all_boards?
      ping('Unsubscribed', { email_type: params[:email_type] }, @user)
      unsubscribe_for_email_type(params[:email_type])

      flash[:success] = "You have been unsubscribed."
    else
      flash[:failure] = "You could not be unsubscribed at this time. Please try again."
    end

    redirect_to path_after_unsubscribe
  end

  private

    def unsubscribe_for_email_type(email_type)
      case email_type
      when "activity"
        unsubscribe_activity
      when "explore"
        unsubscribe_explore
      else
        unsubscribe_default
      end
    end

    def unsubscribe_activity
      bm = @user.board_memberships.where(demo_id: params[:demo_id]).first

      if bm.present?
        bm.update_attributes(send_weekly_activity_report: false)
      end
    end

    def unsubscribe_explore
      @user.update_attributes(receives_explore_email: false)
    end

    def unsubscribe_default
      bm = @user.board_memberships.where(demo_id: params[:demo_id]).first

      if bm.present?
        bm.update_attributes(notification_pref_cd: BoardMembership.unsubscribe)
      end
    end

    def copy_for_new_unsubscribe(email_type)
      case email_type
      when "activity"
        "You will no longer receives weekly activity emails from Airbo."
      when "explore"
        "You will no longer receive Explore emails from Airbo."
      else
        "You may miss important updates about your benefits and other important programs from your employer."
      end
    end

    def path_after_unsubscribe
      if current_user.present?
        activity_path
      else
        sign_in_path
      end
    end
end
