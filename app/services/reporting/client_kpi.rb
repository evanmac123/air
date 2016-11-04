
require 'rails_date_range'
module Reporting

  class ClientKpi
    attr_reader :data, :start, :finish_date, :interval, :demo

    def initialize(args)
      opts = args.delete_if{|k,v|v.nil?}
      opts = defaults.merge(opts)
      @data ={}
      @demo = opts[:demo]
      @interval=opts[:interval]
      @start = opts[:beg_date].send("beginning_of_#{@interval}")
      @finish_date = opts[:end_date].send("end_of_day")
      initialize_report_data_hash
      run
    end

    def run
      do_mrr
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

    def do_mrr
      user = Reporting::Db::UserActivation.new(demo,start, finish_date, interval)
      partition = data[:user]
      user.eligibles.each do |res|
        populate_stats res, partition[:eligibles]
      end
    end

   def percent_by_period activity, all_events, target
     data[:intervals].each do|d|
       occurrences = activity[d][:total]
       possible_occurrences = all_events[d][:total].to_i
       calc_activity_conversion target[d], possible_occurrences, occurrences
     end
   end


   def eligible_users
     data[:user][:eligibles]
   end

   def populate_stats res, kpi
     timestamp= Date.parse(res.interval)
     return if timestamp < start.to_date

     period = kpi[timestamp]
     period[:current] = res.interval_count.to_i
     period[:total] = res.cumulative_count.to_i
   end

    def initialize_report_data_hash
      prepare_empty_hash
      init_intervals
    end

    def init_intervals
      period = "#{interval}s".to_sym

      r = RailsDateRange.new(start, finish_date).every({period => 1})
      r.each do |timestamp|
        d = timestamp.to_date
        data[:intervals] << d
        init_users  d
        init_activity d
      end
    end

    def prepare_empty_hash
      data[:mrr]={
      }
      data[:intervals]=[]
    end
  end
end
