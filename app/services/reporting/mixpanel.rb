module Reporting
  module Mixpanel


    class Report
      def initialize opts
        parse_dates(opts)
        @params= config.reverse_merge!(opts)
        @mixpanel = AirboMixpanelClient.new
      end


      def raw_data
        @raw_data ||= @mixpanel.request(endpoint,@params)
      end

      def result_data
        raw_data.fetch("data",{})
      end

      def client
        @mixpanel
      end

      def endpoint
        raise "You need to implement endpoint  in a subclass"
      end 


      def parse_dates opts
        @from = opts.delete(:from_date) || Date.today.beginning_of_week(:sunday).prev_week(:sunday).at_midnight
        @to = opts.delete(:to_date) || @from.end_of_week(:sunday).end_of_day
      end

      def config
        {
          from_date: date_format(@from), 
          to_date:  date_format(@to),
        }
      end



      private
      def date_format d
        d.strftime "%Y-%m-%d"
      end

    end
  end
end
