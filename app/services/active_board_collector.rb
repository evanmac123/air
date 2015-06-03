require 'ostruct'

class ActiveBoardCollector

  def initialize opts={}
    @admin_board_memberships = opts[:selected_boards] || load_memberships
    validate_report_dates opts
    map_admins_to_boards
		collect
  end

  def active_boards
    @active_boards ||=collect
  end

	def send_mail_notifications
    active_boards.each do |active_board|
			send_for_admin(active_board)
    end
	end

	def send_for_admin(active_board)
		active_board.admins.each do |admin|
			BoardActivityMailer.notify(active_board.board, admin, active_board.tiles, @beg_date, @end_date).deliver
    end
	end

	def  board_admins board
     @board_admins[board]
	end

  private
  def collect
    obj = Struct.new(:board, :admins, :tiles )
    @active_boards = []
    @board_admins.each do |board, admins| 
      tile_collector =ActiveTileCollector.new(board, @beg_date, @end_date)
      tiles = tile_collector.collect
      @active_boards.push obj.new(board,admins,tiles ) if tiles.any?
    end

    @active_boards
  end


  def validate_report_dates opts
    period_start = opts[:beg_date]
    period_end = opts[:end_date]

    if period_start && period_end && period_start.is_a?(Time) && 
      period_end.is_a?(Time) && period_start < period_end

      @beg_date = period_start 
      @end_date = period_end 
    else
      #NOTE Default to last week
      @beg_date = Date.today.beginning_of_week(:sunday).prev_week(:sunday).at_midnight
      @end_date = @beg_date.end_of_week(:sunday).end_of_day
    end
  end

  def map_admins_to_boards
    @board_admins = Hash.new{|h,k|h[k]=[]}
    @admin_board_memberships.each do |mem| 
      @board_admins[mem.demo].push(mem.user)
    end
  end


	def load_memberships

		BoardMembership.select(BoardMembership.arel_table[Arel.star]).where(
			BoardMembership.arel_table[:is_client_admin].eq('t').and(User.arel_table[:send_weekly_activity_report].eq('t')).or(
				BoardMembership.arel_table[:is_current].eq('t').and(
					User.arel_table[:is_client_admin].eq('t').and(User.arel_table[:send_weekly_activity_report].eq('t'))
				)
			)
		).joins(
			BoardMembership.arel_table.join(User.arel_table).on(
				User.arel_table[:id].eq(BoardMembership.arel_table[:user_id])
			).join_sources
)	end

end


