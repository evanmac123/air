class UserBoardMigrator

  Summary = Struct.new(:from, :to, :from_id, :to_id, :perform, :user_ids, :results)

  attr_accessor :summary, :from_bm, :from_bms, :to_bm, :to_bms

  def initialize user_ids, from, to
    @ids = user_ids
    @users = User.where("id in (?)", @ids).order("id asc")
    @from_board = Demo.find(from)
    @to_board = Demo.find(to)
    @from_bms = @from_board.board_memberships.where("user_id in (?)",@ids).all
    @to_bms = @to_board.board_memberships.where("user_id in (?)", @ids).all

    setup_summary
  end



  def execute perform=false
    @summary.perform = perform
    @users.each do|user|
      from_bm = from_bms.select{|u|u.user_id == user.id}.first
      to_bm = to_bms.select{|u|u.user_id == user.id}.first || user.board_memberships.build(demo: @to_board)

      calculate_points user, from_bm, to_bm

      if perform
        User.transaction do
          to_bm.save
          user.save
          from_bm.destroy
        end
      end
    end
    @summary
  end

  def calculate_points user, from, to
    starting_user_points = user.points
    starting_from_points = from.points
    starting_to_points = to.points

    user.points = starting_user_points + starting_from_points + starting_to_points
    to.points = user.points 

    add_to_confirmation_report({
      id: user.id, 
      user: user.name, 
      starting_user_points: starting_user_points,
      from_board_points: starting_from_points, 
      to_board_starting_points: starting_to_points, 
      final_user_points: user.points,
      to_board_points: to.points
    });
  end

  def setup_summary
    @summary = Summary.new
    @summary.user_ids = @ids.join(",")
    @summary.from_id = @from_board.id 
    @summary.to_id = @to_board.id
    @summary.from = @from_board.name
    @summary.to = @to_board.name
    @summary.results = []
  end

  def add_to_confirmation_report data
    @summary.results.push(data)
  end

end
