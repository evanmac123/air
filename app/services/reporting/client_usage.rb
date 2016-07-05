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
        do_tile_activity data, demo, start, finish, interval
      end

      data

    end

    class << self
      private
      def do_user_activation data, demo,start, finish, interval
        activation = Reporting::Db::UserActivation.new(demo,start, finish, interval)

        total_eligible = activation.total_eligible
        data[:activation][:total_eligible] = total_eligible

        activation.activated.each do |res|
          populate_stats res, data[:activation], start do |period|
            period[:activation_pct] = res.cumulative_count.to_f/total_eligible.to_f
          end
        end

      end

      def do_tile_activity data, demo,start, finish, interval
        activity = Reporting::Db::TileActivity.new(demo,start, finish, interval)

        activity.posts.each do |res|
          populate_stats res, data[:tile_activity][:posts], start
        end

        activity.views.each do |res|
          populate_stats res, data[:tile_activity][:views], start
        end

        activity.completions.each do |res|
          populate_stats res, data[:tile_activity][:completions], start
        end

        #data[timestamp][:tile_activity][:views_over_available] =activity.views_over_available
        #data[timestamp][:tile_activity][:completions_over_views] =activity.completions_over_views
      end



      def populate_stats res, stat, start, &block
          timestamp= Date.parse(res.interval)
          return if timestamp < start.to_date
          period = stat[timestamp]
          period[:current] = res.interval_count
          period[:total] = res.cumulative_count
          yield period if block_given?
      end


      #Prepolutates empty hash for for each period interval of the date range
      def initialize_data_set data, start, finish
        r = RailsDateRange.new(start, finish).every(weeks:1)
        r.each do |timestamp|
          d = timestamp.to_date
          init_activation data, d
          init_activity data, d
        end
      end


      def init_activation data, d
          activation = data[:activation][d]={}
          activation[:current] =0 
          activation[:total] =0 
      end

      def init_activity data, d

          activity = data[:tile_activity]
          activity[:posts][d]={current:0, total:0}
          activity[:views][d]={current:0, total:0}
          activity[:completions][d]={current:0, total:0}

      end

    end
  end
end
