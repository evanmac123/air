module Reporting
  class KpiReportingBase
    MONTHLY = "months"
    WEEKLY = "weeks"

    def get_data_by_date_and_interval sdate, edate, interval
      build_data_set(row_set(to_array_of_record_hashes(raw_data(sdate, edate, interval))))
    end

    def to_array_of_record_hashes results
      results.map(&:attributes)
    end

    def get_data_by_date_and_interval sdate, edate, interval
      build_data_set(row_set(to_array_of_record_hashes(raw_data(sdate, edate, interval))))
    end

    def build_data_set rows 
      container = HashWithIndifferentAccess.new(kpi_fields)
      return container if rows.empty? 
      container.each do|field, sub_hash|
        sub_hash[:values] = rows[field]
      end
      add_group_separators(container)
      container.merge!(aliased_kpis(container))
      container
    end


    def grouped_chart_series_names
      opts = chart_series_names
      inverse_opts = opts.invert
      grouped_opts = {}
      sections.map do |name, keys|
        grp =inverse_opts.slice(*keys)
        grouped_opts[name]=grp.invert.to_a
      end
      grouped_opts.to_a
    end

    def raw_data sdate, edate, interval=Metrics::WEEKLY
      sdate, edate = interval== Metrics::WEEKLY ? [sdate.beginning_of_week, edate.end_of_week] : [sdate.beginning_of_month, edate.end_of_month]
      db_fields.by_date_range_and_interval(sdate, edate, interval)
    end

    def query_select_fields
      kpi_fields.keys.join(",")
    end 

    def row_set res
      fields = res.map(&:keys).flatten.uniq
      values = res.map(&:values).transpose
      Hash[fields.zip(values)]
    end

    def group_separators 
      { }
    end

    def aliased_kpis container
      {}
    end

    def add_group_separators(container)
      group_separators.each do |key, label|
        add_group_separator(container, key, label)
      end
      container
    end

    def add_group_separator container, key, label
      colspan = container["from_date"]["values"].count + 1
      container[key]= {
        label: label,
        colspan: colspan,
        type: "grp",
        indent: 0,
        values: []
      }
      container
    end
  end
end
