require 'rails_date_range'
module Reporting 

  class ClientUsage

    def self.run (args) #demo, beg_date=3.months.ago, end_date=Date.today, interval="week"

      data ={}
      args = args.delete_if{|k,v|v.nil?}
      opts = defaults.reverse_merge(args)
      start = opts[:beg_date].beginning_of_week
      finish = opts[:end_date].beginning_of_week
      demo = opts[:demo]
      interval=opts[:interval]
      initialize_report_data_hash demo,data,start, finish, interval

      if demo
        do_user_activation data, demo, start, finish, interval
        do_tile_activity data, demo, start, finish, interval
      end

      data #should be fully initialized with subkeys even if the demo is not provided #TODO throw argument error

    end

    class << self

      private

      def defaults 
        { beg_date:3.months.ago, end_date:Date.today, interval:"week"}

      end

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

      end


      def populate_stats res, stat, start, &block
        timestamp= Date.parse(res.interval)
        return if timestamp < start.to_date
        period = stat[timestamp]
        period[:current] = res.interval_count
        period[:total] = res.cumulative_count
        yield period if block_given?
      end


      def initialize_report_data_hash demo, data, start, finish
        prepare_empty_hash demo, data, start, finish
        init_intervals data, start, finish
      end

      def init_intervals data, start, finish
       r = RailsDateRange.new(start, finish).every(weeks:1)
        r.each do |timestamp|
          d = timestamp.to_date
          init_activation data, d
          init_activity data, d
        end
      end

      def prepare_empty_hash demo, data, start, finish

        data[:demo_id]= demo
        data[:beg_date]= start
        data[:end_date] = finish
        data[:activation]={} 
        data[:tile_activity]= {
          posts:{}, 
          views:{}, 
          completions:{} 
        }

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
