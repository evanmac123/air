require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueOrganizationsWithPostedTiles < UniqueSegmentedEventsBase

      def configure opts
        opts.merge!({
          event: "Tile Posted",
          unit: "week",
          type: "unique",
          where: %Q|properties["organization"] != "#{AIRBO_ORG_ID}" and ("client admin" in properties["user_type"]) and (defined (properties["user_type"])) and (properties["board_type"] == "Paid")|,
          on: 'string(properties["organization"])',
        })
      end
    end
  end
end
