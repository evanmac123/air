require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class ClientAdminWithUniqueExploreTileViews < UniqueEventsBase

      def configure opts
        opts.merge!({
          event: "Tile - Viewed in Explore",
          where: where_condition,
          type: 'unique',
        })
      end

    end
  end
end
