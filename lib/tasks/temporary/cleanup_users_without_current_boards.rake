namespace :db do
  namespace :admin do
    desc "Cleanup users without current boards"
    task cleanup_users_without_current_boards: :environment do
      puts "Looking for lost users..."
      users = User.all.reject { |u| u.current_board_membership != nil }

      puts "#{users.count} users are lost.  Helping them find their way..."
      users.each { |u|
        if u.board_memberships.empty?
          puts "#{u.name} has no boards. Destroying..."
          u.destroy
        elsif u.board_memberships.where(is_current: true).empty?
          puts "#{u.name} has no current board.  Moving to another board..."
          u.board_memberships.first.update_attributes(is_current: true)
        end
      }

      puts "All users have been accounted for."
    end
  end
end

# rake db:admin:cleanup_users_without_current_boards
