module AccountClaimer
  class EmailClaimer < Base
    protected

    def find_claimed_user_by_from
      User.claimed.where("email ILIKE ?", @from.like_escape).first
    end
    
    def number_to_join_game_with
      User.next_dummy_number
    end

    def existing_user_claimed_message
      Mailer.delay.already_claimed(@from, @claimed_user_with_this_claim_code.id)
    end
  end
end
