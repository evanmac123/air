require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesPostedByMediaSource < TotalSegmentedByEventType

      def configure opts
        opts.merge!({
          event: "Tile Posted",
          type: "general",
          where: where_condition ,
          on: 'properties["media_source"]',
        })
      end
    end
  end
end
