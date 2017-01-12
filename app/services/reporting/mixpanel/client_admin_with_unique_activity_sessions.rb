require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class ClientAdminWithUniqueActivitySessions < UniqueEventsBase

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          where: where_condition,
          type: 'unique',
        })
      end

    end
  end
end
