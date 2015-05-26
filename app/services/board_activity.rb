require 'ostruct'

class BoardActivity
	attr_accessor :beg_date, :end_date, :admin_board_memberships

	def initialize opts={}
		@admin_board_memberships = opts[:selected_boards] || BoardMembership.admins
		period_start = opts[:period_start]
		period_end = opts[:period_end]

		if period_start && period_end && period_start.is_a?(DateTime) < period_end.is_a?(DateTime)
			@beg_date = period_start 
			@end_date = period_end 
		else
			#NOTE Default to last week
			@beg_date = Date.today.beginning_of_week(:sunday).prev_week(:sunday).at_midnight
			@end_date = beg_date.end_of_week(:sunday).end_of_day
		end

		map_admins_to_boards

	end

	def boards
		@user_boards
	end

 def process
	 @user_boards.each do |board| 
		 reporting_period =BoardReportingPeriod.new(board, beg_date, end_date)
		 if reporting_period.has_tile_activity?  
			 reporting_period.collect_active_tiles
		 end
	 end
 end

 private

 def map_admins_to_boards
		@user_boards = Hash.new{|h,k|h[k]=[]}
		@admin_board_memberships.includes(demo: [tiles: [:tile_viewings, :tile_completions]]).each do |mem|
			@user_boards[mem.demo].push(mem.user.name)
		end
 end

 class BoardReportingPeriod 
	 attr_accessor :board, :beg_date, :end_date
	 def	initialize board, beg_date, end_date
		 @beg_date = beg_date 
		 @end_date = end_date 
		 @board = board 
	 end

	 def has_tile_activity?
		 viewings.any? || completions.any?
	 end

	 def viewings beg_date, end_date
		 @viewings ||=board.tile_viewings.for_period(beg_date, end_date)
	 end

	 def completions beg_date, end_date
		 @completions ||= board.tile_completions.for_period(beg_date, end_date)
	 end

	 def collect_active_tiles
		 rep = Struct.new(:board_id, :active_tiles)
		 rep.new(board.id, viewings.map(&:id) | completions.map(:id))
	 end
 end
end
