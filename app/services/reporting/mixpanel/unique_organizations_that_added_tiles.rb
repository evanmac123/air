require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueOrganizationsThatAddedTiles < UniqueSegmentedEventsBase

      def configure opts
        opts.merge!({
          event: "Tile - New",
          type: "unique",
          on: 'string(properties["organization"])',
          where: %Q|(properties["user_type"] == "client admin") and (properties["board_type"] == "Paid") and properties["organization"] != "#{AIRBO_ORG_ID}"|,
        })
      end
    end
  end
end
