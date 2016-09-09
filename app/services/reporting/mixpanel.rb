module Reporting
  module Mixpanel


    class Report
      def initialize opts
        parse_dates(opts)
        @params= opts.reverse_merge!(config)
        @mixpanel = AirboMixpanelClient.new
      end

      def data
        @data ||= parse_and_transform(extract_report_data)
      end


      def raw_data
        @raw_data ||= @mixpanel.request(endpoint,@params)
      end

      def client
        @mixpanel
      end


      protected

      def parse_and_transform values
        raise "You need to implement endpoint  in a subclass"
      end

      def endpoint
        raise "You need to implement endpoint  in a subclass"
      end 

      def parse_dates opts
        @from = opts.delete(:from_date) || Date.today.beginning_of_week(:sunday).prev_week(:sunday).at_midnight
        @to = opts.delete(:to_date) || start.end_of_week(:sunday).end_of_day
      end

      def config
        {
          from_date: date_format(@from), 
          to_date:  date_format(@to),
          unit: "week",
          type: "general"
        }
      end

      private

      def date_format d
        d.strftime "%Y-%m-%d"
      end

      def extract_report_data 
        raw_data.fetch("data", {}).fetch("values", [])
      end
    end
  end
end
