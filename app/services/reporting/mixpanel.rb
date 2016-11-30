module Reporting
  module Mixpanel

    module MixpanelUnsegmentedResult
      def by_reporting_period 
        series.each do |date|
          values.each do |event, data|
            @summary_by_date[date] = data[date]
          end
        end

        @summary_by_date
      end
    end

    module Segmentation
      def endpoint
        "segmentation"
      end
    end

    module MixpanelSegmentedResult
      def by_reporting_period
        series.each do |date|
          values.each do |segment, data|
            @summary_by_date[date][segment] = data[date]
          end
        end
      end
    end

    class Report
      attr_reader :from, :to

      def initialize opts
        parse_dates(configure(opts))
        @summary_by_date = {} 
        @params= config.reverse_merge!(opts).with_indifferent_access
        @mixpanel = AirboMixpanelClient.new
        init_data_hash
      end

      def init_data_hash
        series.inject(@summary_by_date) do |h, k|
          h[k]={}
          h
        end
      end

      def run
        by_reporting_period
        @summary_by_date
      end

      def raw_data
        @raw_data ||= @mixpanel.request(endpoint,@params)
      end

      def result_data
        raw_data.fetch("data",{})
      end

      def values
        @values ||=result_data.fetch("values", {})
      end

      def series
        @series ||= result_data.fetch("series", [])
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
