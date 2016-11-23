require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalByEventType < Report 

      def initialize opts
        super
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
        "segmentation"
      end
    end
  end
end
