class ClientKpiReportPresenter < BasePresenter 

  presents :report

  delegate :series_for_key, 
    :data, 
    :start, 
    :finish_date, 
    :interval, 
    :demo, 
    to: :report

  def eligible_users type
    data_cells([:user, :eligibles], type)
  end


  def user_activations type
    data_cells([:user, :activations], type)
  end

  def user_activations_pct type
    data_cells([:user, :activation_pct], type, true) 
  end

  def tiles_posted type
    data_cells([:tile_activity, :posts], type)
  end


  def tiles_viewed type
    data_cells([:tile_activity, :views], type)
  end

  def tiles_views_pct type
    data_cells([:tile_activity, :views_pct], type, true)
  end


  def tiles_completed type
    data_cells([:tile_activity, :completions], type)
  end

  def tiles_completions_pct type
    data_cells([:tile_activity, :completions_pct], type, true)
  end


  def data_cells bread_crumb, leaf, as_pct=false
    tds=""
    series_for_key(bread_crumb, leaf).each do |val|
      val = as_pct ? (val*100).round(2): val
      tds+=content_tag(:td,  val)
    end
    raw tds
  end

  def interval_headers
    tds=""
    data[:intervals].each do |interval|
      tds += content_tag :th, interval.strftime("%m-%d-%y")
    end
    raw tds
  end

  def interval_count pad=0
    data[:intervals].size + pad
  end

  def row_group_header caption, pad=1 
   content_tag :th, caption,  class: "group-hdr", colspan: data[:intervals].size + pad
  end

  def to_csv

    CSV.generate do |csv|

      csv << [""] + data[:intervals]
      data[:kpis].each do|kpi|
        key,val = kpi[0], kpi[1]
        hdr_col = generate_hdr_colum(key, val)
        col_data  = series_for_key(key, val).map {|v| v}
        csv << hdr_col+ col_data 
      end
    end
  end

  def generate_hdr_colum key, val
    kpi = key.dup << val
    [kpi.map{|s|s.to_s.titleize}.join(" ")]
  end


end
