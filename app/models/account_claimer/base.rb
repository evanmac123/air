module AccountClaimer
  class Base
    def initialize(from, to, claim_information, options={})
      @from = from
      @to = to
      @claim_information = claim_information
      @normalized_claim_information = @claim_information.gsub(/\W+/, '').downcase
      @options = options
    end

    def claim
      User.transaction do
        if user_with_this_contact = find_claimed_user_by_from
          if User.find_by_claim_code(@normalized_claim_information)
            return ["You've already claimed your account, and have #{user_with_this_contact.points} pts. If you're trying to credit another user, ask them to check their username with the MYID command.", false]
          else
            return nil
          end
        end

        claim_state_machine = ClaimStateMachine.find_by_to(@to)
        @user, error_message = claim_state_machine.find_unique_user(@from, @normalized_claim_information)

        if @user
          if @user.unclaimed?
            @user.mark_as_claimed(attributes_to_join_game_with)
            @user.forgot_password!
            welcome_message = @user.finish_claim
            after_joining_hook

            success(welcome_message)
          else
            handle_reclaim(@user, error_message)
          end
        else
          failure(error_message)
        end
      end
      
    end

    protected

    def after_joining_hook
    end

    def interpolate(input)
      input.gsub("@\{claim_information\}", @normalized_claim_information)
    end

    def attributes_to_join_game_with
      {:channel => channel_name}
    end

    def success(welcome_message)
      [welcome_message, true]
    end

    def failure(error_message)
      [interpolate(error_message), false]
    end

    def handle_reclaim(user, error_message)
      failure(error_message)
    end
  end
end
