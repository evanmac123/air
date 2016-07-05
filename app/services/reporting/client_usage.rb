require 'rails_date_range'
module Reporting 

  class ClientUsage

    def self.run demo, beg_date=3.months.ago, end_date =Date.today, interval="week"
      start = beg_date.beginning_of_week
      finish = end_date.beginning_of_week

      data = {
        demo_id: demo,
        beg_date: start,
        end_date: finish,
        activation:{}, 
        tile_activity: {
          posts:{}, 
          views:{}, 
          completions:{} 
        }
      }

      initialize_data_set data, start, finish

      if demo
        do_user_activation data, demo, start, finish, interval
        #do_tile_activity data, demo, start, finish, interval
      end

      data

    end

    class << self
      private
      def do_user_activation data, demo,start, finish, interval
        activation = Reporting::Db::UserActivation.new(demo,start, finish, interval)

        data[:total_eligible] = activation.total_eligible

        activation.activated.each do |res|
          timestamp= Date.parse(res.interval)
          data[timestamp][:activation][:total_activated] = res.count
          data[timestamp][:activation][:activation_pct] = res.count.to_f/data[:total_eligible].to_f
        end

        activation.newly_activated.each do |res|
          timestamp= Date.parse(res.interval)
          data[timestamp][:activation][:newly_activated] = res.count
        end

      end

      def do_tile_activity data, demo,start, finish, interval
        activity = Reporting::Db::TileActivity.new(demo,start, finish, interval)
        data[interval][:tile_activity][:posted] = activity.posted
        data[interval][:tile_activity][:available] = activity.available
        data[interval][:tile_activity][:views] = activity.views
        data[interval][:tile_activity][:completions] = activity.completions
        data[interval][:tile_activity][:views_over_available] =activity.views_over_available
        data[interval][:tile_activity][:completions_over_views] =activity.completions_over_views
      end


      #Prepolutates empty hash for for each period interval of the date range
      def initialize_data_set data, start, finish

        r = RailsDateRange.new(start, finish).every(weeks:1)
        r.each do |timestamp|
          d = timestamp.to_date
          data[:activation][d]={}
          data[:activation][d][:current] =0 
          data[:activation][d][:total] =0 
          data[:tile_activity][:posts][d]={}
          data[:tile_activity][:views][d]={}
          data[:tile_activity][:completions][d]={}

          data[:tile_activity][:posts][d][:current] =0 
          data[:tile_activity][:posts][d][:total] = 0 
          data[:tile_activity][:views][d][:current] =0 
          data[:tile_activity][:views][d][:total] = 0 
          data[:tile_activity][:completions][d][:current] =0 
          data[:tile_activity][:completions][d][:total] = 0 
        end

      end
    end
  end
end
