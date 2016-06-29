module Reporting
  module Mixpanel


    class Report
      def initialize beg_date=nil, end_date=nil
        @mixpanel = AirboMixpanelClient.new
        @beg_date = beg_date || Date.today.beginning_of_week(:sunday).prev_week(:sunday).at_midnight
        @end_date = end_date || @beg_date.end_of_week(:sunday).end_of_day

        @date_range = {
          from_date: date_format(@beg_date), 
          to_date:  date_format(@end_date)
        }
      end

      def pull
        params.merge! @date_range
        result =  @mixpanel.request(endpoint, params)
        raw_data = extract_report_data result
        handle_result raw_data
      end


      def handle_result raw_data
        parse_and_transform raw_data
      end

      protected

      def parse_and_transform data
        #noop
      end

      def endpoint
        raise "You need to implement endpoint  in a subclass"
      end 

      def params
        {}
      end

      private

      def date_format d
        d.strftime "%Y-%m-%d"
      end

      def extract_report_data result
        result.fetch("data", {}).fetch("values", [])
      end
    end
  end
end
