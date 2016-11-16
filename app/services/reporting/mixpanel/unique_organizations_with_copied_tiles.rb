require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueOrganizationsWithCopiedTiles < SegmentedUniqueActivitySessionsBase

      def configure opts
        opts.merge!({
          event: "Explore page - Interaction", 
          unit: "week",
          type: "unique",
          on: 'string(properties["organization"])',
          where: %Q|(properties["action"] == "Clicked Copy")|,
        })
      end
    end
  end
end
