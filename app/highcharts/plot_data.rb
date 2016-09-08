class PlotData
  attr_reader :period, :action_query
  delegate  :point_interval, to: :period

  def initialize(period, action_query, value_type, data=nil)
    @period = period
    @action_query = action_query
    @value_type = value_type
    @data = data
  end

  def values
    @data ||=cumulate data_hash.values
  end

  def max_value
   values.max
  end

  protected
    def cumulate values
      if @value_type == 'cumulative'
        sum = 0
        values.map{ |x| sum += x }
      else
        values
      end
    end

    def data_hash
      filled_actions = {}
      period.each_point do |point|
        filled_actions[point] = grouped_actions[point].to_i
      end
      filled_actions
    end

    def grouped_actions
      # i.e. hourly:
      # => {"2015-08-19 11:00:00"=>12, "2015-08-19 10:00:00"=>27, "2015-08-19 13:00:00"=>1}
      @grouped_actions ||= action_query.query
    end
end
