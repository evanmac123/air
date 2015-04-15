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

    def channel_name
      :sms
    end

    def send_welcome_email_if_wanted
      return nil if @user.email.blank?
      Mailer.delay.set_password(@user.id)
    end
  end
end
