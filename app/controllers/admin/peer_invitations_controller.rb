class Admin::PeerInvitationsController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def show
    if params[:commit].present?
      start_time = parse_time_string(params[:start_time])
      end_time = parse_time_string(params[:end_time])

      @invitation_count = @demo.peer_invitations.between_times(start_time, end_time).count
      @start_time_description = start_time_description(start_time)
      @end_time_description = end_time_description(end_time)
    end
  end

  protected

  def parse_time_string(time_string)
    if time_string.present?
      Chronic.parse(time_string)
    else
      nil
    end
  end

  def start_time_description(time)
    if time
      time.to_s
    else
      "the beginning of time"
    end
  end

  def end_time_description(time)
    if time
      time.to_s
    else
      "just now"
    end
  end
end
