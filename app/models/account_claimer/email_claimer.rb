module AccountClaimer
  class EmailClaimer < Base
    protected

    def find_existing_user
      User.where("email = ? AND accepted_invitation_at IS NOT NULL", @from).first
    end

    def number_to_join_game_with
      User.next_dummy_number
    end
  end
end
