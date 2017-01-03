require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TileCreationFunnel < FunnelBase

      def configure opts
        opts.merge!({
          funnel_id: MIXPANEL_FUNNEL_REPORTS["Tile Creation"],
        })
      end

    end
  end
end
