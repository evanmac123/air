module Reporting
  module Mixpanel

    module Segmentation
      def endpoint
        "segmentation"
      end
    end

    module MixpanelUnsegmentedResult
      def by_reporting_period 
        series.each do |date|
          values.each do |event, data|
            @summary_by_date[date] = data[date]
          end
        end
      end

      def get_count date=nil
        run
        date.nil? ? @summary_by_date.values.first : @summary_by_date[date]
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

      #TODO is there a more elegant way to do this
      def get_count date = nil
        run
        data = date.nil? ?  @summary_by_date.values.first : @summary_by_date[date]
        data.select{|k,v| v>0}.count
      end

      def get_count_by_segment(segment, date = nil)
        run
        results_by_segment(date)[segment]
      end

      def sum date=nil
        run
        results_by_segment(date).values.sum
      end

      def results_by_segment date=nil
        date.nil?  ? @summary_by_date.values.first : @summary_by_date[date]
      end

    end

    class Report
      attr_reader :from, :to

      def initialize options
        @summary_by_date = {} 
        @options = options.dup
        @params = configure(get_date_range_config).with_indifferent_access
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
      end

      def summary_by_date
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
        raise "You need to implement endpoint  in a subclass"
      end

      def get_date_range_config
        from = @options.delete(:from_date) || Date.today.beginning_of_week(:monday)
        to = @options.delete(:to_date) || from.end_of_week(:sunday)
        {
          from_date: date_format(from),
          to_date: date_format(to),
          unit: @options.delete(:unit) || "week"
        }
      end

      private

      def date_format d
        d.strftime "%Y-%m-%d"
      end

    end
  end
end
