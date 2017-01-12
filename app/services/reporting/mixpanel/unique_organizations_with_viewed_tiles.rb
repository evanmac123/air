require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueOrganizationsWithViewedTiles < UniqueSegmentedEventsBase

      def configure opts
        opts.merge!({
          event: "Tile - Viewed in Explore",
          type: "unique",
          where: where_condition,
          on: 'string(properties["organization"])',
        })
      end
    end
  end
end
