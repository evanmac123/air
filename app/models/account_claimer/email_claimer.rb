module AccountClaimer
  class EmailClaimer < Base
    protected

    def find_claimed_user_by_from
      User.claimed.where("email ILIKE ?", @from.like_escape).first
    end
    
    def attributes_to_join_game_with
      super.merge(:email => @from)
    end

    def existing_user_claimed_message
      Mailer.delay.already_claimed(@from, @claimed_user_with_this_claim_code.id)
    end

    def channel_name
      :email
    end

    def handle_reclaim(user, error_message)
      if user.overflow_email.present?
        failure(error_message)
      else
        user.load_personal_email @from
        user.reload
        success("OK, we've got your new email address #{user.email}, and will still remember #{user.overflow_email} too.")
      end
    end
  end
end
