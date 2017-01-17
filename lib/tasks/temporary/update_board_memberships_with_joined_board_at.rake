namespace :admin do
  desc "Update board memberships to have joined board at"
  task update_joined_board_at_on_board_membership: :environment do
    User.claimed.each { |user|
      puts "Updating User #{user.id}"
      user.board_memberships.each do |bm|
        joined_date = user.accepted_invitation_at

        if bm.created_at > joined_date
          joined_date = bm.created_at
        end

        bm.joined_board_at = joined_date
        bm.save
      end
    }
  end
end
