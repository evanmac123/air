class ClientKpiReportPresenter < BasePresenter 

  presents :report

  delegate :series_for_key, 
    :data, 
    :start, 
    :finish_date, 
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

  def interval_headers
    tds=""
    data[:intervals].each do |interval|
      tds += content_tag :th, interval
    end
    raw tds
  end

  def interval_count pad=0
    data[:intervals].size + pad
  end

  def row_group_header caption, pad=0 
   content_tag :th, caption,  colspan: data[:intervals].size + pad
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
