require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class ClientAdminWithUniqueActivitySessions < SegmentedUniqueActivitySessionsBase

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          on: %Q|string(properties["id"])|,
          unit: 'day',
          where:%Q|(properties["user_type"] == "client admin") and (properties["board_type"] == "Paid") and properties["is_test_user"] == false|,
          type: 'unique',
        })
      end

    end
  end
end