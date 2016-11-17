require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueOrganizationsWithCopiedTiles < SegmentedUniqueActivitySessionsBase

      def configure opts
        opts.merge!({
          event: "Explore page - Interaction",
          unit: "day",
          type: "unique",
          on: 'string(properties["organization"])',
          where: %Q|(properties["action"] == "Clicked Copy") and properties["is_test_user"] == false and ("client admin" in properties["user_type"]) and (defined (properties["user_type"]))|,
        })
      end
    end
  end
end
