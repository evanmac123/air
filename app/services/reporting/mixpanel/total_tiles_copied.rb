require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesCopied < TotalByEventType 

      def configure opts
        opts.merge!({
          event: "Explore page - Interaction",
          type: "general",
          where: %Q|(properties["user_type"] == "client admin") and properties["is_test_user"] == false and (properties["action"] == "Clicked Copy")|,
          unit: "week"
        })
      end
    end
  end
end
