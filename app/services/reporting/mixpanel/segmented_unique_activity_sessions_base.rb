require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class SegmentUniqueActivitySessionsBase < Report

      def initialize opts #{from_date: ?, to_date: ?}
        super(configure(opts))
        @summary_by_date = {} 
        @endpoint= "segmentation"
      end

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          on: %Q|string(properties["id"])|,
          unit: 'week',
          type: 'unique',
          where: %Q|(properties["user_type"] == "client admin") and (properties["board_type"] == "Paid") and properties["is_test_user"] == false|
        })
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
        @endpoint
      end

      private

      def result_data
        raw_data.fetch("data",{})
      end

    end
  end
end
