module AccountClaimer
  class EmailClaimer < Base
    protected

    def find_demo_by_to(to)
      normalized = to.gsub(/^</, '').gsub(/>$/, '').downcase
      Demo.find_by_email(normalized)
    end

    def find_claimed_user_by_from
      User.claimed.where("email ILIKE ?", @from.like_escape).first
    end
    
    def attributes_to_join_game_with
      super.merge(:email => @from)
    end

    def existing_user_claimed_message
      Mailer.delay_mail(:already_claimed, @from, @claimed_user_with_this_claim_code.id)
    end

    def channel_name
      :email
    end

    def handle_reclaim(user, error_message)
      if user.overflow_email.present?
        failure(error_message)
      else
        had_email_already = user.email.present?

        user.load_personal_email @from
        user.reload

        success_message = if had_email_already
                            "OK, we've got your new email address #{user.email}, and will still remember #{user.overflow_email} too."
                          else
                            "OK, we've now got your email address #{user.email}."
                          end
        success(success_message)
      end
    end
  end
end
