require 'pry'
require 'mixpanel_client'
class AirboMixpanelClient

  MULTISEGMENT_ENDPOINT = "segmentation/multiseg"

  def initialize
    @client ||= Mixpanel::Client.new( api_key: ENV['MIXPANEL_API_KEY'],  api_secret: ENV['MIXPANEL_API_SECRET'])
  end

  def activity_sessions_by_user_type_and_game from = 1.week.ago, to= 1.day.ago
    extract_values (request( MULTISEGMENT_ENDPOINT, activity_sessions_by_user_type_and_game_params(from, to)))
  end

  private

  def extract_values result
    result["data"]["values"]
  end

  def activity_sessions_by_user_type_and_game_params from, to
    return {
      event: 'Activity Session - New',
      from_date: date_format(from),
      to_date: date_format(to),
      type: 'unique',
      unit: 'week',
      inner: 'properties["user_type"]',
      outer: 'properties["game"]'
    }
  end

  def request endpoint, params
    client.request(endpoint, params)
  end

  def client
    @client
  end

  def date_format d
    d.strftime("%Y-%m-%d")
  end




end 
