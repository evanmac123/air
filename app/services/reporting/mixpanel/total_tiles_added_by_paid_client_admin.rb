require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesAddedByPaidClientAdmin < TotalSegmentedByEventType

      def configure opts
        opts.merge!({

          event: "Tile - New",
          type: "general",
          where: %Q|(properties["user_type"] == "client admin") and (properties["board_type"] == "Paid") and properties["organization"] != "#{AIRBO_ORG_ID}"|,
          on: 'properties["tile_source"]',
          unit: "week"
        })
      end
    end
  end
end
