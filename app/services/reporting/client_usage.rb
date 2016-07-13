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
      data
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
      user = Reporting::Db::UserActivation.new(demo,start, finish, interval)

      user.eligibles.each do |res|
        populate_stats res, data[:user][:eligibles]
      end

      user.activations.each do |res|
        populate_stats res, data[:user][:activations] 
      end

      calc_activation_percent
    end

    def calc_activation_percent
      data[:intervals].each do|interval|
        data[:user][:activation_pct][interval][:total] = data[:user][:activations][interval][:total].to_f/data[:user][:eligibles][interval][:total].to_f
      end
    end

    def do_tile_activity 
      partition = data[:tile_activity]
      activity = Reporting::Db::TileActivity.new(demo,start, finish, interval)

      activity.posts.each do |res|
        populate_stats res, partition[:posts]
      end

      activity.views.each do |res|
        populate_stats res, partition[:views]
      end

      activity.completions.each do |res|
        populate_stats res, partition[:completions]
      end

    end


    def populate_stats res, stat
      timestamp= Date.parse(res.interval)
      return if timestamp < start.to_date

      period = stat[timestamp]
      period[:current] = res.interval_count
      period[:total] = res.cumulative_count
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
        init_users  d
        init_activity d
      end
    end



    def prepare_empty_hash
      data[:user]={
        eligibles:{},
        activations:{},
        activation_pct:{}
      }

      data[:tile_activity]= {
        posts:{},
        views:{},
        completions:{}
      }
      data[:kpis] = [
        [[:user, :eligibles], :total],
        [[:user, :eligibles], :current],
        [[:user, :activations], :total],
        [[:user, :activations], :current],
        [[:user, :activation_pct], :total],
        [[:user, :activation_pct], :current],
        [[:tile_activity, :posts], :total],
        [[:tile_activity, :posts], :current],
        [[:tile_activity, :views], :total],
        [[:tile_activity, :views], :current],
        [[:tile_activity, :completions], :total],
        [[:tile_activity, :completions], :current]
      ]
      data[:intervals]=[]
    end


    def init_users  d
      user = data[:user]
      user[:eligibles][d]={current:0, total:0}
      user[:activations][d]={current:0, total:0}
      user[:activation_pct][d]={total:0}
    end

    def init_activity d

      activity = data[:tile_activity]
      activity[:posts][d]={current:0, total:0}
      activity[:views][d]={current:0, total:0}
      activity[:completions][d]={current:0, total:0}
    end



  end
end
