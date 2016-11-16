require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalClientAdminActivitySessions < Report 

      def initialize opts
        super(configure(opts))
        @endpoint = "segmentation"
      end

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          unit: 'week',
          where:%Q|(properties["user_type"] == "client admin") and (properties["board_type"] == "Paid") and properties["is_test_user"] == false|,
          type: 'general',
        })
      end

      def count_series
        series.each do |date|
          @summary_by_date[date] = with_events_by_date(date)
        end
        @summary_by_date
      end

      def values_for_segment
        result_data.fetch("values", {})
      end

      def values
        values_for_segment.values
      end

      def endpoint
        @endpoint
      end
    end
  end
end
