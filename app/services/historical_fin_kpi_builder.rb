class HistoricalFinKpiBuilder

  class << self

    def build kpi

      m = Metrics.new
      m.starting_mrr = kpi.starting_mrr
      m.added_mrr = kpi.added_mrr
      m.upgrade_mrr = kpi.upgrade_mrr
      m.new_cust_mrr = kpi.new_customer_mrr
      m.churned_mrr = kpi.churned_mrr
      m.downgrade_mrr = kpi.downgrade_mrr
      m.churned_customer_mrr = kpi.churned_customer_mrr
      m.net_changed_mrr = kpi.net_changed_mrr
      m.net_churned_mrr = kpi.net_churned_mrr
      m.current_mrr = kpi.current_mrr
      m.possible_churn_mrr =kpi.possible_churn_mrr
      m.percent_churned_mrr =kpi.percent_churned_mrr
      m.starting_customers = kpi.starting_customer_count
      m.added_customers = kpi.added_customer_count
      m.churned_customers = kpi.churned_customer_count
      m.net_change_customers = kpi.net_change_in_customers
      m.current_customers = kpi.current_customer_count
      m.possible_churn_customers = kpi.possible_churn_customer_count
      m.percent_churned_customers = kpi.percent_churned_customers
      m.amt_booked =kpi.amt_booked
      m.added_customer_amt_booked =kpi.added_customer_amt_booked
      m.renewal_amt_booked = kpi.renewal_amt_booked
      m.upgrade_amt_booked = kpi.upgrade_amt_booked
      m.weekending_date = kpi.edate
      m.report_date = kpi.sdate
      m.save
    end

    def build_weekly(from=nil)
      if has_data?
        sdate = min_start(from).beginning_of_week
        edate = sdate.end_of_week

        while sdate < Date.today do 
          build FinancialsCalcService.new(sdate, edate)

          sdate = sdate.advance(weeks: 1)
          edate = sdate.end_of_week
        end
      end
    end

    def build_monthly(from=nil)
      if has_data?
        sdate = min_start(from).beginning_of_month
        edate = sdate.end_of_month

        while sdate < Date.today do 
          build FinancialsCalcService.new(sdate, edate)

          sdate = sdate.advance(months: 1)
          edate = sdate.end_of_month
        end
      end
    end

    def min_start(date)
      date || Contract.min_activity_date
    end

    def has_data?
      if Contract.count==0 || Organization.count == 0
        Rails.logger.warn "No Data"
        false
      else
        true
      end
    end
  end
end






