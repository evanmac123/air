require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueActivitySessionAfterTimePeriodInDays < UniqueSegmentedEventsBase

      RANGES = {
        first: { label: "30",  min:1, max: 30},
        second: {label: "60",  min: 31, max: 60},
        third: { label: "120", min: 61, max: 120}
      }

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          on: %Q|string(properties["days_since_activated"])|,
          unit: 'week',
          where:%Q|
          (properties["days_since_activated"] >= #{RANGES[:first][:min]} and properties["days_since_activated"] <= #{RANGES[:first][:max]})
          or (properties["days_since_activated"] >= #{RANGES[:second][:min]} and properties["days_since_activated"] <= #{RANGES[:second][:max]})
          or (properties["days_since_activated"] >=#{RANGES[:third][:min]} and properties["days_since_activated"] <= #{RANGES[:third][:max]})
          |,
          type: 'unique',
        })
      end

      def by_reporting_period
        series.each do |date|
          values.each do |days, data|
           period = days_to_period(days)
           @summary_by_date[date][period] += data[date]
          end
        end
      end

      def init_data_hash
        series.inject(@summary_by_date) do |h, k| 
          h[k]={RANGES[:first][:label]=>0,RANGES[:second][:label]=>0,RANGES[:third][:label]=>0}
          h
        end
      end


      private

      def days_to_period days
        num_days = days.to_i
        case 
        when num_days.between?(RANGES[:first][:min], RANGES[:first][:max])
          RANGES[:first][:label]
        when num_days.between?(RANGES[:second][:min],RANGES[:second][:max])
          RANGES[:second][:label]
        when num_days.between?(RANGES[:third][:min],RANGES[:third][:max])
          RANGES[:third][:label]
        end
      end


     #---------------------------
      # used for testing purpose uncomment if needed
      #---------------------------
      
      #def raw_data
         #sample_data
      #end

      #def sample_data

        #{
          #"legend_size"=> 3, 
          #"data"=> {
            #"series"=> ["2016-10-24", "2016-10-31", "2016-11-07", "2016-11-14", "2016-11-21", "2016-11-28"], 
            #"values"=> {
              #"30"=> {"2016-11-28"=> 1, "2016-11-21"=> 0, "2016-10-24"=> 0, "2016-11-07"=> 0, "2016-10-31"=> 0, "2016-11-14"=> 0}, 
              #"40"=> {"2016-11-28"=> 1, "2016-11-21"=> 0, "2016-10-24"=> 0, "2016-11-07"=> 0, "2016-10-31"=> 0, "2016-11-14"=> 0}, 
              #"60"=> {"2016-11-28"=> 1, "2016-11-21"=> 0, "2016-10-24"=> 0, "2016-11-07"=> 0, "2016-10-31"=> 0, "2016-11-14"=> 0}, 
              #"120"=> {"2016-11-28"=> 1, "2016-11-21"=> 0, "2016-10-24"=> 0, "2016-11-07"=> 0, "2016-10-31"=> 0, "2016-11-14"=> 0}
            #}
          #}
        #}
      #end

    end
  end
end

