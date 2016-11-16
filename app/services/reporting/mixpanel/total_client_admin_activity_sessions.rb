require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalClientAdminActivitySessions < TotalByEventType 

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          unit: 'week',
          where:%Q|(properties["user_type"] == "client admin") and (properties["board_type"] == "Paid") and properties["is_test_user"] == false|,
          type: 'general',
        })
      end

    end
  end
end
