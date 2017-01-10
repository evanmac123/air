require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalClientAdminActivitySessions < TotalByEventType

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          where: where_condition,
          type: 'general',
        })
      end

    end
  end
end
