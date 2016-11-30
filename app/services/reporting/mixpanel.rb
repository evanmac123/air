module Reporting
  module Mixpanel


    class Report
      attr_reader :from, :to

      def initialize opts
        parse_dates(configure(opts))
        @params= config.reverse_merge!(opts).with_indifferent_access
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

      def configure opts
        opts
      end


      def parse_dates opts
        @from = opts.delete(:from_date) || Date.today.beginning_of_week(:monday)
        @to = opts.delete(:to_date) || @from.end_of_week(:sunday).end_of_day
      end

      def config
        {
          from_date: formatted_from, 
          to_date: formatted_to
        }
      end

      def formatted_from
        date_format(@from)
      end

      def formatted_to
        date_format(@to)
      end

      private
      def date_format d
        d.strftime "%Y-%m-%d"
      end

    end
  end
end
