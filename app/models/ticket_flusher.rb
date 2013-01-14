class TicketFlusher
  def initialize(user_ids)
    @user_ids = user_ids
  end

  def perform
    @user_ids.each {|user_id| User.find(user_id).delay.flush_tickets}
  end
end
