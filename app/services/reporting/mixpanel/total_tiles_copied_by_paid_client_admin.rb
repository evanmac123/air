require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesCopiedByPaidClientAdmin < TotalByEventType

      def configure opts
        opts.merge!({
          event: "Explore page - Interaction",
          type: "general",
          where: %Q|(properties["user_type"] == "client admin") and properties["organization"] != "#{AIRBO_ORG_ID}" and (properties["board_type"] == "Paid") and (properties["action"] == "Clicked Copy")|,
          unit: "week"
        })
      end
    end
  end
end
