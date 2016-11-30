require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueSegmentedEventsBase < UniqueEventsBase

      def initialize opts
        super
        init_data_hash
      end

      def by_reporting_period
        series.each do |date|
          values.each do |segment, data|
            @summary_by_date[date][segment] = data[date]
          end
        end
      end

      def init_data_hash
        series.inject(@summary_by_date) do |h, k|
          h[k]={}
          h
        end
      end


    end



  end
end
