require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueOrganizationsThatAddedTiles < UniqueSegmentedEventsBase

      def configure opts
        opts.merge!({
          event: "Tile - New",
          unit: "week",
          type: "unique",
          on: 'string(properties["organization"])',
          where: %Q|(properties["user_type"] == "client admin") and (properties["board_type"] == "Paid") and properties["is_test_user"] == false|,
        })
      end
    end
  end
end
