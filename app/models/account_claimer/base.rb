module AccountClaimer
  class Base
    def initialize(from, claim_code, options={})
      @from = from
      @claim_code = claim_code
      @normalized_claim_code = @claim_code.gsub(/\W+/, '')
      @options = options
    end

    def claim
      User.transaction do
        users = User.find(:all, :conditions => ["claim_code ILIKE ?", @normalized_claim_code.like_escape])

        if users.count > 1
          return "There's more than one person with that code. Please try sending us your first name along with the code (for example: John Smith enters \"john jsmith\")."
        end

        @user = users.first || User.claimable_by_first_name_and_claim_code(@claim_code)

        return nil unless @user

        if (@user_with_this_contact = find_claimed_user_by_from)
          return I18n.t(
            'activerecord.models.user.claim_account.already_claimed_sms',
            :default => "You've already claimed your account, and have %{current_points} pts. If you're trying to credit another user, ask them to check their username with the MYID command.",
            :current_points => @user_with_this_contact.points
          )
        end

        if (@claimed_user_with_this_claim_code = find_claimed_user_by_claim_code)
          return existing_user_claimed_message
        end

        @user.mark_as_claimed(number_to_join_game_with)
      end
      
      @user.forgot_password!
      @welcome_message = @user.finish_claim
      after_joining_hook

      @welcome_message
    end

    protected

    def after_joining_hook
    end

    def find_claimed_user_by_claim_code
      User.claimed.where("claim_code ILIKE ?", @normalized_claim_code.like_escape).first
    end
  end
end
