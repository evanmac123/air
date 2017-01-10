require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesViewedInExplore < TotalByEventType

      def configure opts
        opts.merge!({
          event: "Tile - Viewed in Explore",
          type: "general",
          where: where_condition
        })
      end
    end
  end
end
