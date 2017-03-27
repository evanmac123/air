require 'mixpanel_client'
class AirboMixpanelClient
  def initialize
    @client ||= $mixpanel_client
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
