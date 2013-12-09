class User::PointAndTicketSummarizer
  def initialize(user)
    @user = user
  end

  def point_and_ticket_summary(prefix = [])
    return "" unless @user.demo.use_post_act_summaries

    result_parts = prefix.clone
    result_parts << point_summary
    result_parts << ticket_summary

    ' ' + result_parts.map(&:capitalize).compact.join(', ') + '.'
  end

  protected

  def point_summary
    if @user.demo.ticket_threshold > 0
      "points #{@user.to_ticket_progress_calculator.pretty_point_fraction}"
    else
      "points #{@user.points}"
    end
  end

  def ticket_summary
    "Tix #{@user.tickets}"
  end
end
