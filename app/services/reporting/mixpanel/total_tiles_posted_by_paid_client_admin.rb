require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesPostedByPaidClientAdmin < TotalByEventType

      def configure opts
        opts.merge!({
          event: "Tile Posted",
          type: "general",
          where:%Q|properties["organization"] != "#{AIRBO_ORG_ID}" and (properties["user_type"] == "client admin") and (properties["board_type"] == "Paid")|,
        })
      end
    end
  end
end
