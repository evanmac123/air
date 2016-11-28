require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueEventsBase < Report

      def initialize opts #{from_date: ?, to_date: ?}
        super
        @summary_by_date = {} 
      end

      def count_greater_than_zero_by_date_series
         series.each do |date|
           @summary_by_date[date] = with_events_by_date(date)
         end
         @summary_by_date
      end

      def with_events_by_date date
        values.select{ |segment, data| data[date]>0}.count
      end

      def values
        @values ||=result_data.fetch("values", {})
      end

      def series
        @series ||= result_data.fetch("series", [])
      end

      def endpoint
        "segmentation"
      end

    end
  end
end
