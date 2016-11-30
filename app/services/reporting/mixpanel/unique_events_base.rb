require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueEventsBase < Report

      def initialize opts #{from_date: ?, to_date: ?}
        super
        @summary_by_date = {} 
      end

      def run
        by_reporting_period
        summary_by_date
      end

      def values
        @values ||=result_data.fetch("values", {})
      end

      def series
        @series ||= result_data.fetch("series", [])
      end

      def summary_by_date
        @summary_by_date
      end

      private
      def by_reporting_period 
        series.each do |date|
          values.each do |event, data|
            @summary_by_date[date] = data[date]
          end
        end
      end

      def endpoint
        "segmentation"
      end

    end
  end
end
