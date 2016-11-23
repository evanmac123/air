require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TileCreationFunnel < Report

      def configure opts
        opts.merge!({
          funnel_id: MIXPANEL_FUNNEL_REPORTS["Tile Creation"],
          interval: 30,
        })
      end

      def endpoint
        "funnels"
      end


    end



  end
end
