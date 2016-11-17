require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueOrganizationsWithPostedTiles < SegmentedUniqueActivitySessionsBase

      def configure opts
        opts.merge!({
          event: "Tile Posted",
          unit: "day",
          type: "unique",
          where: %Q|properties["is_test_user"] == false and ("client admin" in properties["user_type"]) and (defined (properties["user_type"]))|,
          on: 'string(properties["organization"])',
        })
      end
    end
  end
end
