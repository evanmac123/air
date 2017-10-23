class Api::SendgridEventsController < Api::ApiController
  def create
    events = Integrations::SendgridEventsParser.new.track_events(params["_json"])
    render json: events.to_json
  end
end
