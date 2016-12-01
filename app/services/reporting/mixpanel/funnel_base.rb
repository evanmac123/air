require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class FunnelBase < Report

      end

      def endpoint
        "funnels"
      end

      end

      def calc_avg_times_through_funnel
        dates.each do |date|
          @summary_by_date[date] = summarize(date)
        end
        @summary_by_date
      end

      def summarize date
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
