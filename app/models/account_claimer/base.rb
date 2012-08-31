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
            demo = user_with_this_contact.demo
            already_claimed_message = demo.already_claimed_message(user_with_this_contact)

            return [already_claimed_message, false]
          else
            return nil
          end
        end

        @demo = find_demo_by_to(@to)
        claim_state_machine = @demo.claim_state_machine
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
