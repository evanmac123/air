require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class OrganizationWithUniqueActivitySessions < UniqueSegmentedEventsBase

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          where: where_condition,
          on: %Q|string(properties["organization"])|,
          type: 'unique',
        })
      end
    end
  end
end
