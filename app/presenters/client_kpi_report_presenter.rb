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
    tds=""
    series_for_key(bread_crumb, leaf).each do |val|
      tds+=content_tag(:td,  val)
    end
    raw tds
  end



  def to_csv

    CSV.generate do |csv|

      csv << [""] + data[:intervals]
      data[:kpis].each do|kpi|
        key,val = kpi[0], kpi[1]
        hdr_col = generate_hrd_colum(key, val)
        col_data  = series_for_key(key, val).map {|v| v}
        csv << hdr_col+ col_data 
      end
    end
  end

  def generate_hrd_colum key, val
    kpi = key.dup << val
    [kpi.map{|s|s.to_s.titleize}.join(" ")]
  end


end
