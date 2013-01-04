class AdminsController < AdminBaseController
  def show
    @current_user = current_user
    @demos = Demo.alphabetical

    min_date = Act.minimum :created_at
    ids = Act.pluck :id

    @highchart = LazyHighCharts::HighChart.new('graph', style: '') do |f|
      f.chart(defaultSeriesType: 'area')
      f.series(name: 'Act ID', data: ids, point_start: min_date.to_time.to_i, color: '#4D7A36')
      f.xAxis(type: :datetime, title: {text: 'What the fuck'})
    end

    render :template => 'admin/show'
  end
end
