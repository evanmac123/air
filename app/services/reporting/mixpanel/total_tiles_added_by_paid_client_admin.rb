require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesAddedByPaidClientAdmin < TotalSegmentedByEventType

      def configure opts
        opts.merge!({

          event: "Tile - New",
          type: "general",
          where: where_condition ,
          on: 'properties["tile_source"]',
        })
      end
    end
  end
end
