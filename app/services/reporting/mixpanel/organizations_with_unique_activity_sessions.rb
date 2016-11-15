require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class OrganizationWithUniqueActivitySessions < SegmentedUniqueActivitySessionsBase

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          on: %Q|string(properties["organization"])|,
          unit: 'week',
          type: 'unique',
        })
      end
    end
  end
end
