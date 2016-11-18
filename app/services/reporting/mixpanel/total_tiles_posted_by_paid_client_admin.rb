require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesPostedByPaidClientAdmin < TotalByEventType

      def configure opts
        opts.merge!({
          event: "Tile Posted",
          type: "general",
          where:%Q|properties["is_test_user"] == false and (properties["user_type"] == "client admin") and (properties["board_type"] == "Paid")|,
          unit: "day"
        })
      end
    end
  end
end