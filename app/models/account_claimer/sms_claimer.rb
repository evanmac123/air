module AccountClaimer
  class SMSClaimer < Base
    protected

    def find_claimed_user_by_from
      User.claimed.where(:phone_number => @from).first
    end

    def number_to_join_game_with
      @from
    end

    def after_joining_hook
      #Mailer.delay.set_password(@user.id)
    end

    def existing_user_claimed_message
      "That ID \"#{@claimed_user_with_this_claim_code.claim_code}\" is already taken. If you're trying to register your account, please text in your own ID first by itself."
    end
  end
end
