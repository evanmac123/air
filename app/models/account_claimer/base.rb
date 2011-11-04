module AccountClaimer
  class Base
    def initialize(from, claim_code, options={})
      @from = from
      @claim_code = claim_code
      @options = options
    end

    def claim
      User.transaction do
        normalized_claim_code = @claim_code.gsub(/\W+/, '')
        users = User.find(:all, :conditions => ["claim_code ILIKE ?", normalized_claim_code.like_escape])

        if users.count > 1
          return "There's more than one person with that code. Please try sending us your first name along with the code (for example: John Smith enters \"john jsmith\")."
        end

        @user = users.first || User.claimable_by_email_address(@claim_code) || User.claimable_by_first_name_and_claim_code(@claim_code)

        return nil unless @user

        if (existing_user = find_existing_user)
          return I18n.t(
            'activerecord.models.user.claim_account.already_claimed_sms',
            :default => "You've already claimed your account, and have %{current_points} pts. If you're trying to credit another user, ask them to check their user ID with the MYID command.",
            :current_points => existing_user.points
          )
        end

        @user.forgot_password!
        @welcome_message = @user.join_game(number_to_join_game_with)
        after_joining_hook
      end

      @welcome_message
    end

    protected

    def after_joining_hook
    end
  end
end
