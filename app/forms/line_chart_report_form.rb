class LineChartReportForm
  include ActiveModel::Conversion


  attr_reader :action_type,
    :value_type,
    :new_chart,
    :period

  delegate :interval_type,
    :period,
    :date_range_type,
    :start_date,
    :end_date,
    :date_range_types_disabled_option,
    :date_range_types_select_list,
    :show_dates_selection,
    :show_date_range,
    to: :time_handler

  def initialize params = {}
    @action_type = params.delete(:action_type) || action_types[0]
    @value_type = params.delete(:value_type) || value_types[0]

    params = initial_params if params.empty?

    @new_chart = params[:new_chart]

    @time_handler = TimeHandler.new(
      params.slice(
        :interval_type,
        :start_date,
        :end_date,
        :date_range_type,
        :changed_field,
        :new_chart
      )
    ).handle

  end

  def self.model_name
    raise NotImplementedError.new("Must be implemented in subclass")
  end

  def self.interval_types_select_list
    Period::INTERVAL_TYPES.collect {|name| [ name.capitalize, name ] }
  end

  def value_types
    ['cumulative', 'activity'] #TODO change to "activity" to "Per Period"
  end

  def action_type_class action
    # TODO: this method needs to be here for the UI
    action + " " + (action == action_type ? "selected" : "")
  end

  def action_num(action)
    self.send(action.to_sym) 
  end

  def changed_field
    nil
  end

  def persisted?
    false
  end

  def action_types
    raise NotImplementedError.new("Must be implemented in subclass")
  end

  def value_types_select_list
    value_types.collect {|name| [ name.capitalize, name ] }
  end

  def plot_data
    raise NotImplementedError.new("Must be implemented in subclass")
  end


  protected

  def initial_params
    {
      start_date: 1.week.ago.strftime("%b %d, %Y"),
      end_date: Time.now.strftime("%b %d, %Y"),
      changed_field: 'end_date', # to trigger time handler
      new_chart: true
    }
  end

  private

   def time_handler
     @time_handler
   end


end
