require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueSegmentedEventsBase < UniqueEventsBase
      include MixpanelSegmentedResult

      def initialize opts
        super
        init_data_hash
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
