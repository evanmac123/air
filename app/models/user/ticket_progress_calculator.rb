class User
  class TicketProgressCalculator
    def initialize(user)
      @user = user
      @ticket_threshold = user.demo.ticket_threshold
      @ticket_threshold_base = user.ticket_threshold_base || 0
      @points = user.points
    end

    def last_point_goal
      (@points - @ticket_threshold_base) - ((@points - @ticket_threshold_base) % @ticket_threshold)
    end

    def next_point_goal
      last_point_goal + @ticket_threshold
    end
 
    def points_towards_next_threshold
      @points - last_point_goal - @ticket_threshold_base
    end

    def percent_towards_next_threshold 
      return 100.0 unless next_point_goal
      point_fraction * 100.0
    end

    def point_fraction
      return 1.0 unless next_point_goal

      point_denominator = @ticket_threshold
      return 0.0 if point_denominator == 0

      points = points_towards_next_threshold
      points.to_f / point_denominator
    end

    def pretty_point_fraction
      points = points_towards_next_threshold
      point_denominator = @ticket_threshold
      "#{points}/#{point_denominator}"
    end
  end

  class NullTicketProgressCalculator
    def initialize
    end

    def points_towards_next_threshold
      0
    end
  end
end
