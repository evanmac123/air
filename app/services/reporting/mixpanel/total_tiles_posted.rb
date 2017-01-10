require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesPosted < TotalByEventType

      def configure opts
        opts.merge!({
          event: "Tile Posted",
          type: "general",
          where: where_condition,
        })
      end
    end
  end
end
