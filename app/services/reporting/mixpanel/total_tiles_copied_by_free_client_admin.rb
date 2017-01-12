require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesCopiedByFreeClientAdmin < TotalByEventType
      def configure opts
        opts.merge!({
          event: "Explore page - Interaction",
          type: "general",
          where: %Q|(properties["user_type"] == "client admin") #{excluded_orgs} and (properties["board_type"] == "Free") and (properties["action"] == "Clicked Copy")|,
        })
      end
    end
  end
end
