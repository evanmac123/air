
require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueOrganizationsThatCreatedTilesFromScratch < UniqueSegmentedEventsBase

      def configure opts
        opts.merge!({
          event: "Tile - New",
          type: "unique",
          on: 'string(properties["organization"])',
          where: where_condition,
        })
      end

      def where_condition
        %Q|#{super} and (properties["tile_source"] == "Self Created")|
      end

    end
  end
end
