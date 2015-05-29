require 'ostruct'

class ActiveBoardCollector

  def initialize opts={}
    @admin_board_memberships = opts[:selected_boards] || BoardMembership.admins
    validate_report_dates opts
    map_admins_to_boards
  end

  def boards
    @active_boards ||=collect
  end

  private
  def collect
    rep = Struct.new(:board_id, :admins, :tiles )
    @active_boards = []
    @board_admins.each do |board, admins| 
      tile_collector =ActiveTileCollector.new(board, @beg_date, @end_date)
      tiles = tile_collector.collect
      @active_boards.push rep.new(board,admins,tiles ) if tiles.any?
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
      @end_date = beg_date.end_of_week(:sunday).end_of_day
    end
  end

  def map_admins_to_boards
    @board_admins = Hash.new{|h,k|h[k]=[]}
    @admin_board_memberships.includes(
      demo: [tiles: [:tile_viewings, :tile_completions]]).each do |mem|

      @board_admins[mem.demo].push(mem.user.name)
    end
  end


end
