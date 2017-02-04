class UserBoardMigrator

  def initialize user_ids, from, to
    @user_ids = user_ids
    @from_board_id = from
    @to_board_id = to
    @summary = {results:[]}
  end



  def execute commit=false
    @users = User.where(@user_ids)
    @from_board = Demo.find(@from_board_id)
    @to_board = Demo.find(@to_board_id)
    @from_bms = @from_board.board_memberships.where("user_id in", user_ids).all
    @to_bms = @to_board.board_memberships.where("user_id in", user_ids)


    @summary[:from] = @from_board.name
    @summary[:to] = @to_board.name
    @summary[:commited] = commit

    @users.each do|user|

      #set from_points to 0 user not in from board
      from_bm = from_bms.select{u|u.id == user.id}.first
      to_bm = to_bms.select{u|u.id == user.id}.first

      from_points  = from_bm.nil? ? 0 : from_bm.points

      #check if user in to board
      if to_bm.nil?
        to_bm = user.board_memberships.build
      end

      starting_points = user.points
      points = starting_points + from_points + to_bm.points
      user.points = points
      to_bm.points = points


      add_to_confirmation_report user, starting_points, from_points, to_points

      if commit
        User.transaction do
          user.save
          to_bm.save
          from_bm.destroy
        end
      end
    end
    return @summary
  end

  def add_to_confirmation_report user, starting, from, to
    @summary[:results].push({name: user.name, orig_points: starting, new_points: user.points, :from_points: from, to_points: to } 
  end

end
