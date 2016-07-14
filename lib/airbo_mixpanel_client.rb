require 'mixpanel_client'
class AirboMixpanelClient


  def initialize
    @client ||= Mixpanel::Client.new( api_key: ENV['MIXPANEL_API_KEY'],  api_secret: ENV['MIXPANEL_API_SECRET'])
  end

  def request endpoint, params
    client.request(endpoint, params)
  end
  private

  def client
    @client
  end

  def date_format d
    d.strftime("%Y-%m-%d")
  end

end
