require 'rails_date_range'
module Reporting 

  class ClientUsage
    attr_reader :data, :start, :finish, :interval, :demo
    def initialize(args) 
      opts = args.delete_if{|k,v|v.nil?}
      opts = defaults.merge(opts)
      @data ={}
      @start = opts[:beg_date].beginning_of_week
      @finish = opts[:end_date].beginning_of_week
      @demo = opts[:demo]
      @interval=opts[:interval]
      initialize_report_data_hash 
      run
    end

    def run 
      if @demo
        do_user_activation
        do_tile_activity
      end
    end

    def series_for_key nodes,leaf
      data[:intervals].map do |timestamp| 
       fetch_for_path(nodes, timestamp, leaf)
      end
    end

    def fetch_for_path nodes, timestamp, leaf
      arr =nodes.dup
      arr.push timestamp
      arr.push leaf 
      arr.reduce(data){|slice, key| slice[key]}
    end


    private


    def defaults 
      { beg_date:3.months.ago, end_date:Date.today, interval:"week"}

    end

    def do_user_activation
      activation = Reporting::Db::UserActivation.new(demo,start, finish, interval)

      total_eligible = activation.total_eligible
      data[:intervals].each do|interval|
        data[:activation][interval][:total_eligible] = total_eligible
      end

      activation.activated.each do |res|
        populate_stats res, data[:activation] do |period|
          period[:activation_pct] = res.cumulative_count.to_f/total_eligible.to_f
        end

      end

    end

    def do_tile_activity 
      activity = Reporting::Db::TileActivity.new(demo,start, finish, interval)

      activity.posts.each do |res|
        populate_stats res, data[:tile_activity][:posts]
      end

      activity.views.each do |res|
        populate_stats res, data[:tile_activity][:views]
      end

      activity.completions.each do |res|
        populate_stats res, data[:tile_activity][:completions]
      end

    end


    def populate_stats res, stat, &block
      timestamp= Date.parse(res.interval)
      return if timestamp < start.to_date

      period = stat[timestamp]
      period[:current] = res.interval_count
      period[:total] = res.cumulative_count

      yield period if block_given?
    end




    def initialize_report_data_hash 
      prepare_empty_hash 
      init_intervals
    end

    def init_intervals
      period = "#{interval}s".to_sym

      r = RailsDateRange.new(start, finish).every({period => 1})

      r.each do |timestamp|
        d = timestamp.to_date
        data[:intervals] << d 
        init_activation  d
        init_activity d
      end
    end



    def prepare_empty_hash
      data[:activation]={} 
      data[:tile_activity]= {
        posts:{}, 
        views:{}, 
        completions:{}
      }
      data[:kpis] = [
        [[:activation], :total_eligible],
        [[:activation], :total],
        [[:activation], :current],
        [[:tile_activity, :posts], :total],
        [[:tile_activity, :posts], :current],
        [[:tile_activity, :views], :total],
        [[:tile_activity, :views], :current],
        [[:tile_activity, :completions], :total],
        [[:tile_activity, :completions], :current]
      ]
      data[:intervals]=[]
    end


    def init_activation  d
      activation = data[:activation][d]={}
      activation[:total_eligible] =0 
      activation[:current] =0 
      activation[:total] =0
    end

    def init_activity d

      activity = data[:tile_activity]
      activity[:posts][d]={current:0, total:0}
      activity[:views][d]={current:0, total:0}
      activity[:completions][d]={current:0, total:0}
    end



  end
end
