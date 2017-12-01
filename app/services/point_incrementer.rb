class PointIncrementer
  def self.call(user:, increment:)
    PointIncrementer.new(user, increment).update_points
  end

  attr_reader :user, :increment, :starting_points
  def initialize(user, increment)
    @user = user # might also be a GuestUser
    @increment = increment
    @starting_points = @user.points
  end

  def update_points
    user.increment(:points, increment)
    add_ticket

    user.save
  end

  private

    def add_ticket
      return unless demo.uses_tickets

      old_point_tranche = ticket_tranche(starting_points)
      new_point_tranche = ticket_tranche(user.points)

      if new_point_tranche > old_point_tranche
        user.increment(:tickets, new_point_tranche - old_point_tranche)
      end
    end

    def ticket_tranche(point_value)
      (point_value - ticket_threshold_base) / demo_ticket_threshold
    end

    def demo
      user.demo
    end

    def demo_ticket_threshold
      demo.ticket_threshold
    end

    def ticket_threshold_base
      user.ticket_threshold_base
    end
end
