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
          where: where_condition,
        })
      end
    end
  end
end
