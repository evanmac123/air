require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class FunnelBase < Report

      def run
        by_reporting_period
      end

      def endpoint
        "funnels"
      end

      def get_avg_time
        run
        @summary_by_date.values.first
      end

      def by_reporting_period
        dates.each do |date|
          @summary_by_date[date] = calc_time_for_steps(date)
        end
        @summary_by_date
      end

      def calc_time_for_steps date
        steps_for_date(date).inject(0) do |t, fun_step|
          t += fun_step["avg_time"] || 0
        end
      end

      def dates
        raw_data.fetch("meta",{}).fetch("dates", {})
      end

      def steps_for_date d
        result_data.fetch(d, {}).fetch("steps", {})
      end
    end


  end
end
