require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesPostedByPaidClientAdminOnOrganization < TotalSegmentedByEventType

      def configure opts
        opts.merge!({
          event: "Tile Posted",
          type: "general",
          where: where_condition,
          on: 'properties["organization"]'
        })
      end
    end
  end
end
