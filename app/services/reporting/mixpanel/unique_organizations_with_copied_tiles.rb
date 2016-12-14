require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueOrganizationsWithCopiedTiles < UniqueSegmentedEventsBase

      def configure opts
        opts.merge!({
          event: "Explore page - Interaction",
          unit: "week",
          type: "unique",
          on: 'string(properties["organization"])',
          where: %Q|(properties["action"] == "Clicked Copy") and properties["organization"] != "#{AIRBO_ORG_ID}" and ("client admin" in properties["user_type"]) and (defined (properties["user_type"]))|,
        })
      end
    end
  end
end
