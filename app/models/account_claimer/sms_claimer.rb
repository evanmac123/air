module AccountClaimer
  class SMSClaimer < Base
    protected

    def find_demo_by_to(to)
      Demo.find_by_phone_number(to)
    end

    def find_claimed_user_by_from
      User.claimed.where(:phone_number => @from).first
    end

    def attributes_to_join_game_with
      super.merge(:phone_number => @from)
    end

    def after_joining_hook
      send_welcome_email_if_wanted
      @user.update_column(:notification_method, 'sms')
    end

    def existing_user_claimed_message
      "That ID \"#{@claimed_user_with_this_claim_code.claim_code}\" is already taken. If you're trying to register your account, please text in your own ID first by itself."
    end

    def channel_name
      :sms
    end

    def send_welcome_email_if_wanted
      return nil if @user.email.blank? || @user.demo.website_locked
      Mailer.delay.set_password(@user.id)
    end
  end
end
