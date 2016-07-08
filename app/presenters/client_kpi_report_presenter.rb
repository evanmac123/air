class ClientKpiReportPresenter < BasePresenter 

  presents :report

  delegate :series_for_key, 
    :data, 
    :start, 
    :finish, 
    :interval, 
    :demo, 
    to: :report

  def data_cells bread_crumb, leaf
    report.series_for_key(bread_crumb, leaf).each do |val|
      content_tag :td,  val
    end
  end

end
