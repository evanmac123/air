module Reporting
  class CustomerSuccessKpiBuilder
    MONTHS = "months"
    WEEKS = "weeks"
    MONTHLY = "monthly"
    WEEKLY = "weekly"

    class << self

      def build kpi

        m = CustSuccessKpi.new

        m.paid_net_promoter_score = kpi.get_paid_net_promoter_score.nps
        m.paid_net_promoter_score_response_count = kpi.paid_net_promoter_score.response_count
        m.total_paid_orgs = kpi.total_paid_orgs
        m.unique_org_with_activity_sessions = kpi.org_unique_activity_sessions
        m.total_paid_client_admins = kpi.total_paid_client_admins
        m.unique_client_admin_with_activity_sessions = kpi.client_admin_unique_activity_sessions
        m.total_paid_client_admin_activity_sessions =  kpi.total_client_admin_activity_sessions
        m.activity_sessions_per_client_admin = kpi.activity_sessions_per_client_admin
        m.total_tiles_viewed_in_explore_by_paid_orgs = kpi.total_tiles_viewed_in_explore
        m.paid_client_admins_who_viewed_tiles_in_explore = kpi.unique_client_admin_with_viewed_tiles_in_explore
        m.tiles_viewed_per_paid_client_admin = kpi.tiles_viewed_per_paid_client_admin
        m.unique_orgs_that_added_tiles = kpi.orgs_that_added_tiles
        m.total_tiles_added_by_paid_client_admin = kpi.total_tiles_added
        m.total_tiles_copied = kpi.total_tiles_added_from_copy
        m.tiles_created_from_scratch = kpi.total_tiles_added_from_scratch
        m.orgs_that_created_tiles_from_scratch = kpi.orgs_that_created_tiles_from_scratch
        m.unique_orgs_that_viewed_tiles_in_explore = kpi.unique_organizations_with_viewed_tiles_in_explore
        m.unique_orgs_that_copied_tiles = kpi.unique_orgs_that_copied_tiles
        m.total_tiles_added_from_scratch_by_paid_client_admin = kpi.total_tiles_added_from_scratch
        m.total_tiles_added_from_copy_by_paid_client_admin = kpi.total_tiles_added_from_copy
        m.orgs_that_posted_tiles = kpi.orgs_that_posted_tiles
        m.total_tiles_posted = kpi.total_tiles_posted

        m.average_tiles_created_from_scratch_per_org_that_created = kpi.average_tiles_created_from_scratch_per_org_that_created
        m.average_tiles_copied_per_org_that_copied = kpi.average_tiles_copied_per_org_that_copied
        m.average_tiles_posted_per_organization_that_posted = kpi.average_tiles_posted_per_organization_that_posted
        m.percent_paid_orgs_view_tile_in_explore = kpi.percent_of_orgs_that_viewed_tiles
        m.percent_engaged_organizations = kpi.percent_engaged_organizations
        m.percent_engaged_client_admin = kpi.percent_engaged_client_admin
        m.percent_orgs_that_added_tiles = kpi.percent_of_orgs_that_added_tiles
        m.percent_of_added_tiles_from_copy = kpi.percent_of_tiles_added_from_copy
        m.percent_of_added_tiles_from_scratch = kpi.percent_of_tiles_added_created_from_scratch
        m.percent_orgs_that_copied_tiles = kpi.percent_orgs_that_copied_tiles
        m.percent_of_added_tiles_from_copy = kpi.percent_of_tiles_added_from_copy
        m.percent_of_added_tiles_from_scratch = kpi.percent_of_tiles_added_created_from_scratch

        m.percent_of_orgs_that_posted_tiles = kpi.percent_of_orgs_that_posted_tiles
        m.tile_completion_rate = kpi.tile_completion_rate
        m.tile_view_rate = kpi.tile_view_rate
        m.tiles_delivered_count = kpi.tiles_delivered_count
        m.from_date = kpi.curr_interval_start
        m.to_date = kpi.curr_interval_end
        m.interval = kpi.interval
        m.tap(&:save)
      end


      def build_current_week
        sdate = Date.current.beginning_of_week
        edate = sdate.end_of_week
        CustSuccessKpi.where({from_date: sdate, to_date: edate, interval: WEEKLY}).delete_all
        build(Reporting::CustomerSuccessKpiCalcService.new(sdate, edate, WEEKLY))
      end

      def build_current_month
        sdate = Date.current.beginning_of_month
        edate = sdate.end_of_month
        CustSuccessKpi.where({from_date: sdate, to_date: edate, interval: MONTHLY}).delete_all
        build(Reporting::CustomerSuccessKpiCalcService.new(sdate, edate, MONTHLY))
      end

      def build_weekly_historicals(from_date=nil)
        if has_data?
          sdate = min_start(from_date).beginning_of_week
          edate = Date.current.end_of_week
          kpi = Reporting::CustomerSuccessKpiCalcService.new(sdate, edate, WEEKLY)
          while kpi.curr_interval_start < edate do
            build(kpi)
            kpi.advance_interval
          end
        end
      end

      def build_monthly_historicals(from_date=nil)
        if has_data?
          sdate = min_start(from_date).beginning_of_month
          kpi = Reporting::CustomerSuccessKpiCalcService.new(sdate, Date.current.beginning_of_month, MONTHLY)
          while kpi.curr_interval_start < Date.current.beginning_of_month do
            build(kpi)
            sdate = kpi.advance_interval
          end
        end
      end

      def min_start(date)
        date || Date.new(2016,11,1)
      end

      def has_data?
        true
      end

    end
  end
end
