module AccountClaimer
  class SMSClaimer < Base
    protected

    def find_existing_user
      User.find_by_phone_number(@from)    
    end

    def number_to_join_game_with
      @from
    end

    def after_joining_hook
      Mailer.delay.set_password(@user.id)
    end
  end
end
