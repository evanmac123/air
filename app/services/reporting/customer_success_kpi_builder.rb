module Reporting
  class CustomerSuccessKpiBuilder
    PAID_CLIENTS_DELIGHTED_TREND = 75029

    attr_accessor :report_date, :from_date, :to_date
    attr_reader :opts, :demo_ids, :demos

    def initialize(report_date = Date.today,  interval = "week") 
      @opts = {}
      @interval = interval
      @report_date = report_date
      @demos = Demo.paid
      @demo_ids = @demos.pluck(:id)
      parse_dates
    end

    def parse_dates
       @interval == "week" ? weekly : monthly
    end

    def monthly
      opts[:from_date] = report_date.beginning_of_month
      opts[:to_date] = report_date.end_of_month.end_of_day
    end

    def weekly
      opts[:from_date] = report_date.beginning_of_week(:monday)
      opts[:to_date] = opts[:from_date].end_of_week(:sunday).end_of_day
    end

    def build
      kpi = CustSuccessKpi.new


      kpi.paid_net_promoter_score = paid_net_promoter_score
      kpi.paid_net_promoter_score_response_count = paid_net_promoter_score.response_count
      kpi.total_paid_orgs = total_paid_orgs
      kpi.unique_org_with_activity_sessions = org_unique_activity_sessions
      kpi.total_paid_client_admins = total_paid_client_admins
      kpi.unique_client_admin_with_activity_sessions = client_admin_unique_activity_sessions
      kpi.total_paid_client_admin_activity_sessions =  total_client_admin_activity_sessions
      kpi.unique_orgs_that_copied_tiles = unique_orgs_that_copied_tiles
      kpi.total_tiles_copied = total_tiles_copied
      kpi.orgs_that_posted_tiles = orgs_that_posted_tiles
      kpi.total_tiles_posted = total_tiles_posted
      kpi.activity_sessions_per_client_admin = activity_sessions_per_client_admin
      kpi.average_tiles_copied_per_org_that_copied = average_tiles_copied_per_org_that_copied
      kpi.average_tiles_posted_per_organization_that_posted = average_tiles_posted_per_organization_that_posted
      kpi.percent_engaged_organizations = percent_engaged_organizations
      kpi.percent_engaged_client_admin = percent_engaged_client_admin
      kpi.percent_orgs_that_copied_tiles = percent_orgs_that_copied_tiles
      kpi.percent_of_orgs_that_posted_tiles = percent_of_orgs_that_posted_tiles

      kpi.percent_retained_post_activation_30_days = retention_by_days("30")
      kpi.percent_retained_post_activation_60_days =  retention_by_days("60")
      kpi.percent_retained_post_activation_120_days =  retention_by_days("120")

      kpi.average_tile_creation_time = avg_tile_creation_time


      #kpi.percent_joined_current =
      #kpi.percent_joined_30_days =
      #kpi.percent_joined_60_days =
      #kpi.percent_joined_120_days =

      kpi.from_date = opts[:to_date]
      kpi.to_date = opts[:to_date]
      kpi.report_date = opts[:from_date]
      kpi.weekending_date = opts[:to_date]
      kpi.save

    end


    # from ----Net promoter score

    def paid_net_promoter_score
      @nps ||= Integrations::NetPromoterScore.get_metrics({ trend: PAID_CLIENTS_DELIGHTED_TREND })
    end


    # --------- From Data base
    #

    def total_paid_orgs
      @total_paid_orgs = Organization.joins(:boards).where(demos: { id: demo_ids }).uniq.count
    end

    def total_paid_client_admins
      @total_paid_client_admins = User.joins(:demo).where(demo: { id: demo_ids } ).where(is_client_admin: true).count
    end

    #----------------------------MIXPANEL DATA ----------------------------

    def org_unique_activity_sessions
      @org_unique_activity_sessions = Reporting::Mixpanel::OrganizationWithUniqueActivitySessions.new(opts).get_count
    end

    def percent_engaged_organizations
      calc_percent(@org_unique_activity_sessions, @total_paid_orgs)
    end

    def client_admin_unique_activity_sessions
      @client_admin_unique_activity_sessions = Reporting::Mixpanel::ClientAdminWithUniqueActivitySessions.new(opts).get_count
    end

    def total_client_admin_activity_sessions
      @total_client_admin_activity_sessions = Reporting::Mixpanel::TotalClientAdminActivitySessions.new(opts).get_count
    end

    def percent_engaged_client_admin
      calc_percent(@client_admin_unique_activity_sessions, @total_paid_client_admins)
    end

    def activity_sessions_per_client_admin
      calc_avg(@total_client_admin_activity_sessions, @total_paid_client_admins)
    end

    def unique_orgs_that_copied_tiles
      @unique_orgs_that_copied_tiles = Reporting::Mixpanel::UniqueOrganizationsWithCopiedTiles.new(opts).get_count
    end

    def total_tiles_copied
      @total_tiles_copied = Reporting::Mixpanel::TotalTilesCopied.new(opts).get_count
    end

    def total_tiles_posted
      @total_tiles_posted = Reporting::Mixpanel::TotalTilesPostedByPaidClientAdmin.new(opts).get_count
    end

    def orgs_that_posted_tiles
      @orgs_that_posted_tiles = Reporting::Mixpanel::UniqueOrganizationsWithPostedTiles.new(opts).get_count
    end

    def retention
      @retention ||= Reporting::Mixpanel::UniqueActivitySessionAfterTimePeriodInDays.new(opts)
    end

    def retention_by_days days
      retention.get_count_by_segment(days)
    end

    def avg_tile_creation_time
      @tile_creation_time = Reporting::Mixpanel::TileCreationFunnel.new(opts).get_avg_time
    end

    def average_tiles_copied_per_org_that_copied
      calc_avg(@total_tiles_copied, @unique_orgs_that_copied_tiles)
    end

    def percent_orgs_that_copied_tiles
      calc_percent(@unique_orgs_that_copied_tiles, @total_paid_orgs)
    end

    def percent_of_orgs_that_posted_tiles
      calc_percent(@orgs_that_posted_tiles, @total_paid_orgs)
    end

    def average_tiles_posted_per_organization_that_posted
      calc_avg(@total_tiles_posted, @orgs_that_posted_tiles)
    end



    #----------Utility Methods
    #


    def formatted_total_completion_time t
      "%2d days %2d hours %2d mins %2d seconds" % [ days(t), hours(t), mins(t), seconds(t)]
    end

    def days t
      t/86400 ==0 ? nil : t/86400
    end

    def hours t
      t/3600%24 == 0 ? nil : t/3600%24
    end

    def mins t
      t/60%60 == 0 ? nil : t/60%60
    end

    def seconds t
      t%60 == 0 ? nil : t%60
    end

    def month
      Date.today.strftime("%m/%y")
    end

    def week
      (Date.today.end_of_week + 1.day).strftime("%m/%d/%y")
    end

    def calc_percent(a, b)
      return 0 if b == 0
      ((a.to_f / b) * 100).round(2)
    end

    def calc_avg(a, b)
      return 0 if b == 0
      (a.to_f / b).round(2)
    end

  end
end
