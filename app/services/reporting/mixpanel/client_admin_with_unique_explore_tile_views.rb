require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class ClientAdminWithUniqueExploreTileViews < UniqueEventsBase

      def configure opts
        opts.merge!({
          event: "Tile - Viewed in Explore",
          where:%Q|(properties["user_type"] == "client admin") and (properties["board_type"] == "Paid") and properties["organization"] != "#{AIRBO_ORG_ID}"|,
          type: 'unique',
        })
      end

    end
  end
end
