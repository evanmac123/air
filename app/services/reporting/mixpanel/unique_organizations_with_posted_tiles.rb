require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueOrganizationsWithPostedTiles < UniqueEventsBase

      def configure opts
        opts.merge!({
          event: "Tile Posted",
          unit: "week",
          type: "unique",
          where: %Q|properties["is_test_user"] == false and ("client admin" in properties["user_type"]) and (defined (properties["user_type"])) and (properties["board_type"] == "Paid")|,
          on: 'string(properties["organization"])',
        })
      end
    end
  end
end
