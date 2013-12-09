class PointIncrementer
  def initialize(user, point_increment)
    @user = user # might also be a GuestUser
    @point_increment = point_increment

    @old_points = @user.points
    @ticket_threshold_base = @user.ticket_threshold_base
    @demo = @user.demo
  end

  def update_points
    @user.increment!(:points, @point_increment)
    add_ticket
  end

  def add_ticket
    return unless @demo.uses_tickets

    new_points = @old_points + @point_increment
    old_point_tranche = ticket_tranche(@old_points)
    new_point_tranche = ticket_tranche(new_points)

    if new_point_tranche > old_point_tranche
      @user.increment!(:tickets)
    end
  end

  def ticket_tranche(point_value)
    (point_value - @ticket_threshold_base) / @demo.ticket_threshold
  end
end
