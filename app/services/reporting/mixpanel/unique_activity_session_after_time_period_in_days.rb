require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueActivitySessionAfterTimePeriodInDays < UniqueEventsBase

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          on: %Q|string(properties["days_since_activated"])|,
          unit: 'week',
          where:%Q|properties["days_since_activated"] == 30 or properties["days_since_activated"] == 60 or properties["days_since_activated"] == 120|,
          type: 'unique',
        })

      end

    end
  end
end
