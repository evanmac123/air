require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesCopied < TotalByEventType

      def configure opts
        opts.merge!({
          event: "Explore page - Interaction",
          type: "general",
          where: %Q|(properties["user_type"] == "client admin") and properties["organization"] != "#{AIRBO_ORG_ID}" and (properties["action"] == "Clicked Copy")|,
        })
      end
    end
  end
end
