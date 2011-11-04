module AccountClaimer
  class SMSClaimer < Base
    protected

    def find_existing_user
      User.where(:phone_number => @from).first ||
      User.where("claim_code ILIKE ? AND accepted_invitation_at IS NOT NULL", @claim_code.like_escape).first
    end

    def number_to_join_game_with
      @from
    end

    def after_joining_hook
      Mailer.delay.set_password(@user.id)
    end
  end
end
