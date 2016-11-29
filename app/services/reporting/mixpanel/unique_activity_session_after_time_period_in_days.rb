require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueActivitySessionAfterTimePeriodInDays < UniqueEventsBase

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          on: %Q|string(properties["days_since_activated"])|,
          unit: 'week',
          where:%Q|properties["days_since_activated"] == 30 or properties["days_since_activated"] == 60 or properties["days_since_activated"] == 120|,
          type: 'unique',
        })

      end

      def init_data_hash

        series.inject(@summary_by_date) do |h, k| 
          h[k]={"30"=>{},"60"=>{},"120"=>{}}
          h
        end
      end

      def reported_by_date
        series.each do |date|
          values.each do |period, data|
           @summary_by_date[date][period]=data[date]
          end
        end
      end

      def values_for_date date
        summary_by_date[data]
      end

      private

      def sample_data

        {
          "legend_size"=> 3, 
          "data"=> {
            "series"=> ["2016-10-24", "2016-10-31", "2016-11-07", "2016-11-14", "2016-11-21", "2016-11-28"], 
            "values"=> {
              "30"=> {"2016-11-28"=> 1, "2016-11-21"=> 0, "2016-10-24"=> 0, "2016-11-07"=> 0, "2016-10-31"=> 0, "2016-11-14"=> 0}, 
              "20"=> {"2016-11-28"=> 1, "2016-11-21"=> 0, "2016-10-24"=> 0, "2016-11-07"=> 0, "2016-10-31"=> 0, "2016-11-14"=> 0}, 
              "120"=> {"2016-11-28"=> 1, "2016-11-21"=> 0, "2016-10-24"=> 0, "2016-11-07"=> 0, "2016-10-31"=> 0, "2016-11-14"=> 0}
            }
          }
        }
      end

    end
  end
end

