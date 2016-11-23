require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class FunnelBase < Report

      def initialize opts
        super 
        @summary_by_date = {} 
        calc_avg_times_through_funnel
      end

      def configure opts
        opts.merge!({
          interval: 30,
        })
      end

      def endpoint
        "funnels"
      end

      def avg_times_through_funnel
        h={}
        @summary_by_date.inject(h) {|h, (d, val)| h[d]=formatted_total_completion_time(val)}
       h 
      end

      def calc_avg_times_through_funnel
        dates.each do |date|
          @summary_by_date[date] = summarize(date)
        end
        @summary_by_date
      end

      def formatted_total_completion_time t
        "%2d days %2d hours %2d mins %2d seconds" % [ days(t), hours(t), mins(t), seconds(t)]
      end

      def days t
        t/86400 ==0 ? nil : t/86400
      end

      def hours t
        t/3600%24 == 0 ? nil : t/3600%24
      end

      def mins t
        t/60%60 == 0 ? nil : t/60%60
      end

      def seconds t
        t%60 == 0 ? nil : t%60
      end

      def summarize date
        steps_for_date(date).inject(0) do |t, fun_step|
          t += fun_step["avg_time"] || 0
        end
      end

      def dates
        raw_data.fetch("meta",{}).fetch("dates", {})
      end
     
      def data
        raw_data.fetch("data", {})
      end

      def steps_for_date d
        result_data.fetch(d, {}).fetch("steps", {})
      end
    end

  end
end
