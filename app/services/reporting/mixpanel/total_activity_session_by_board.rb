require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel

    class TotalActivitySessionByBoard < TotalByEventType

      def initialize opts
        super(configure(opts))
      end

      def data
        @data ||= parse_and_transform(extract_report_data_values)
      end

      def configure opts
        opts.merge!({
          event: 'Activity Session - New',
          where:  %Q|(string(properties["game"]) == "#{opts.delete(:demo_id)}")|,
        })
      end

      def parse_and_transform data_set
        data_set.values.first
      end

      def demo_id
        @demo_id
      end

      def extract_report_data_values
        raw_data.fetch("data", {}).fetch("values", [])
      end
    end
  end
end
