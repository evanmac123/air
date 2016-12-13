module Reporting
  class CustomerSuccessKpiBuilder
    PAID_CLIENTS_DELIGHTED_TREND = 75029
    MONTHLY = "months"
    WEEKLY = "weeks"
    attr_accessor :from_date, :to_date
    attr_reader :opts, :demo_ids, :demos, :report_intervals

    def initialize(from_date = Date.today, to_date = Date.today.end_of_week, interval = WEEKLY) 
      @from_date = from_date
      @to_date = to_date
      @opts = {}
      @interval = interval
      @report_intervals = {}
      @demos = Demo.paid
      @demo_ids = @demos.pluck(:id)
      parse_dates
    end

    def parse_dates
      @interval == WEEKLY ? weekly : monthly
      build_report_intervals
    end

    def monthly
      opts[:from_date] =from_date.beginning_of_month
      opts[:to_date] = to_date.end_of_month.end_of_day
    end

    def weekly
      opts[:from_date] = from_date.beginning_of_week(:monday)
      opts[:to_date] = to_date.end_of_week(:sunday).end_of_day
    end

    def build_report_intervals
      start_int = opts[:from_date] 
      while start_int < opts[:to_date]

        @report_intervals[start_int] = end_interval(start_int)
        start_int = advance_interval(start_int)
      end
    end

    def end_interval s
      @interval == WEEKLY ? s.end_of_week : s.end_of_month
    end

    def advance_interval s
      @interval == WEEKLY ? s.advance(weeks:1) : s.adance(months:1)
    end

    def build
      report_intervals.each do |start_interval, end_interval|
        @start_interval = start_interval.strftime("%Y-%m-%d")

        kpi = CustSuccessKpi.new

        kpi.paid_net_promoter_score = paid_net_promoter_score.nps
        kpi.paid_net_promoter_score_response_count = paid_net_promoter_score.response_count


        #-------------------------------------------------------------------------
        # Engagement
        #-------------------------------------------------------------------------


        #-------------------------------------------------------------------------
        #     Customer Engagement
        #-------------------------------------------------------------------------
        kpi.total_paid_orgs = total_paid_orgs
        kpi.unique_org_with_activity_sessions = org_unique_activity_sessions
        kpi.percent_engaged_organizations = percent_engaged_organizations

        #-------------------------------------------------------------------------
        #     Client Admin Engagement
        #-------------------------------------------------------------------------
        kpi.total_paid_client_admins = total_paid_client_admins
        kpi.unique_client_admin_with_activity_sessions = client_admin_unique_activity_sessions
        kpi.total_paid_client_admin_activity_sessions =  total_client_admin_activity_sessions
        kpi.percent_engaged_client_admin = percent_engaged_client_admin
        kpi.activity_sessions_per_client_admin = activity_sessions_per_client_admin


        #-------------------------------------------------------------------------
        # Planning
        #-------------------------------------------------------------------------

        #-------------------------------------------------------------------------
        #     Explore Engagement
        #-------------------------------------------------------------------------
        kpi.percent_paid_orgs_view_tile_in_explore = nil
        #kpi.paid_orgs_visited_explore = nil
        kpi.total_tiles_viewed_in_explore_by_paid_orgs = nil
        kpi.paid_client_admins_who_viewed_tiles_in_explore = unique_client_admin_with_viewed_tiles_in_explore
        kpi.tiles_viewed_per_paid_client_admin = nil



        #-------------------------------------------------------------------------
        #  Creation 
        #-------------------------------------------------------------------------

        #-------------------------------------------------------------------------
        #     All Added 
        #-------------------------------------------------------------------------

        kpi.percent_orgs_that_added_tiles = percent_of_orgs_that_added_tiles 
        kpi.total_tiles_added_by_paid_client_admin = total_tiles_added #NOTE Extra !!!
        kpi.unique_orgs_that_added_tiles = orgs_that_added_tiles #NOTE Extra !!!
        kpi.percent_of_added_tiles_from_copy = percent_of_tiles_added_from_copy
        kpi.percent_of_added_tiles_from_scratch = percent_of_tiles_added_created_from_scratch
        kpi.total_tiles_copied = total_tiles_copied
        kpi.tiles_created_from_scratch = total_tiles_added_from_scratch
        kpi.orgs_that_created_tiles_from_scratch = orgs_that_created_tiles_from_scratch
        kpi.average_tiles_created_from_scratch_per_org_that_created = nil
        kpi.average_tile_creation_time = avg_tile_creation_time


        kpi.average_tiles_copied_per_org_that_copied = average_tiles_copied_per_org_that_copied
        kpi.percent_orgs_that_copied_tiles = percent_orgs_that_copied_tiles
        kpi.unique_orgs_that_copied_tiles = unique_orgs_that_copied_tiles

        kpi.unique_orgs_that_added_tiles = orgs_that_added_tiles
        kpi.total_tiles_added_from_copy_by_paid_client_admin = total_tiles_added_from_copy
        kpi.total_tiles_added_from_scratch_by_paid_client_admin = total_tiles_added_from_scratch
        kpi.percent_of_added_tiles_from_copy = percent_of_tiles_added_from_copy
        kpi.percent_of_added_tiles_from_scratch = percent_of_tiles_added_created_from_scratch

        #-------------------------------------------------------------------------
        # Retention
        #-------------------------------------------------------------------------
        kpi.percent_retained_post_activation_30_days = retention_by_days("30")
        kpi.percent_retained_post_activation_60_days =  retention_by_days("60")
        kpi.percent_retained_post_activation_120_days =  retention_by_days("120")


        kpi.percent_joined_current = percent_joined_current
        kpi.percent_joined_30_days = percent_joined_30
        kpi.percent_joined_60_days = percent_joined_60
        kpi.percent_joined_120_days = percent_joined_120


        #-------------------------------------------------------------------------
        # Delivery
        #-------------------------------------------------------------------------

        kpi.average_tiles_posted_per_organization_that_posted = average_tiles_posted_per_organization_that_posted
        kpi.percent_of_orgs_that_posted_tiles = percent_of_orgs_that_posted_tiles
        kpi.orgs_that_posted_tiles = orgs_that_posted_tiles
        kpi.total_tiles_posted = total_tiles_posted

        #-------------------------------------------------------------------------
        # meta
        #-------------------------------------------------------------------------

        kpi.from_date = start_interval
        kpi.to_date = end_interval
        kpi.report_date = start_interval
        kpi.weekending_date = end_interval
        kpi.save
      end
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


    #-------------------------------------------------------------------------
    #Engagement
    #-------------------------------------------------------------------------

    def org_unique_activity_sessions
      @org_unique_activity_sessions = Reporting::Mixpanel::OrganizationWithUniqueActivitySessions.new(opts).get_count(@start_interval)
    end

    def percent_engaged_organizations
      calc_percent(@org_unique_activity_sessions, @total_paid_orgs)
    end

    def client_admin_unique_activity_sessions
      @client_admin_unique_activity_sessions = Reporting::Mixpanel::ClientAdminWithUniqueActivitySessions.new(opts).get_count(@start_interval)
    end

    def total_client_admin_activity_sessions
      @total_client_admin_activity_sessions = Reporting::Mixpanel::TotalClientAdminActivitySessions.new(opts).get_count(@start_interval)
    end

    def percent_engaged_client_admin
      calc_percent(@client_admin_unique_activity_sessions, @total_paid_client_admins)
    end

    def activity_sessions_per_client_admin
      calc_avg(@total_client_admin_activity_sessions, client_admin_unique_activity_sessions)
    end


    #-------------------------------------------------------------------------
    # Planning
    #-------------------------------------------------------------------------

    #-------------------------------------------------------------------------
    #     Explore Engagement
    #-------------------------------------------------------------------------


    def unique_client_admin_with_viewed_tiles_in_explore
       @unique_clientd_admin_explore_tile_views =Reporting::Mixpanel::ClientAdminWithUniqueExploreTileViews.new(opts).get_count(@start_interval)
    end
    #TODO missing

    #-------------------------------------------------------------------------
    # creation 
    #-------------------------------------------------------------------------

    def percent_of_orgs_that_added_tiles
      calc_percent(orgs_that_added_tiles, total_paid_orgs)
    end

    def tiles_added_by_paid_client_admins
      @tiles_added ||= Reporting::Mixpanel::TotalTilesAddedByPaidClientAdmin.new(opts)
    end

    def total_tiles_added
      tiles_added_by_paid_client_admins.sum(@start_interval)
    end

    def orgs_that_added_tiles
      @orgs_that_added_tiles ||= Reporting::Mixpanel::UniqueOrganizationsThatAddedTiles.new(opts).get_count(@start_interval)
    end


    def total_tiles_added_from_copy
      tiles_added_by_paid_client_admins.results_by_segment["Explore Page"]
    end

    #FIXME duplicates functionality #total_tiles_added_from_copy 
    def total_tiles_copied
      @total_tiles_copied = Reporting::Mixpanel::TotalTilesCopied.new(opts).get_count(@start_interval)
    end

    def percent_of_tiles_added_from_copy
      calc_percent(total_tiles_added_from_copy,total_tiles_added)
    end

    def percent_of_tiles_added_created_from_scratch
      calc_percent(total_tiles_added_from_scratch,total_tiles_added)
    end

    def unique_orgs_that_copied_tiles
      @unique_orgs_that_copied_tiles ||= Reporting::Mixpanel::UniqueOrganizationsWithCopiedTiles.new(opts).get_count(@start_interval)
    end

    def orgs_that_created_tiles_from_scratch
      @unique_orgs_that_created_tiles ||= Reporting::Mixpanel::UniqueOrganizationsThatCreatedTilesFromScratch.new(opts).get_count(@start_interval)
    end

    def total_tiles_added_from_scratch
      @tiles_created_from_scratch  ||= tiles_added_by_paid_client_admins.results_by_segment["Self Created"]
    end


    def percent_of_orgs_that_added_tiles
      calc_percent(orgs_that_added_tiles, total_paid_orgs)
    end

    def average_tiles_copied_per_org_that_copied
      calc_avg(@total_tiles_copied, @unique_orgs_that_copied_tiles)
    end

    def average_tiles_created_from_scratch_per_org_that_created
      calc_avg(@tiles_created_from_scratch, @unique_orgs_that_created_tiles)
    end


    def avg_tile_creation_time
      @tile_creation_time = Reporting::Mixpanel::TileCreationFunnel.new(opts).get_avg_time
    end





    #-------------------------------------------------------------------------
    #  Retention 
    #-------------------------------------------------------------------------

    def retention
      @retention ||= Reporting::Mixpanel::UniqueActivitySessionAfterTimePeriodInDays.new(opts)
    end

    def retention_by_days days
      #TODO fix implementation
      return nil
      #retention.get_count_by_segment(days)
    end

    #-------------------------------------------------------------------------
    #  Delivery 
    #-------------------------------------------------------------------------

    def percent_of_orgs_that_posted_tiles
      calc_percent(@orgs_that_posted_tiles, @total_paid_orgs)
    end

    def average_tiles_posted_per_organization_that_posted
      calc_avg(@total_tiles_posted, @orgs_that_posted_tiles)
    end

    def percent_joined_current
    end

    def percent_joined_30
    end

    def percent_joined_60
    end

    def percent_joined_120
    end

    #-------------------------------------------------------------------------
    # Delivery
    #-------------------------------------------------------------------------
    def total_tiles_posted
      @total_tiles_posted = Reporting::Mixpanel::TotalTilesPostedByPaidClientAdmin.new(opts).get_count(@start_interval)
    end

    def orgs_that_posted_tiles
      @orgs_that_posted_tiles = Reporting::Mixpanel::UniqueOrganizationsWithPostedTiles.new(opts).get_count(@start_interval)
    end
    #-------------------------------------------------------------------------
    # Other
    #-------------------------------------------------------------------------

    def percent_orgs_that_copied_tiles
      calc_percent(@unique_orgs_that_copied_tiles, @total_paid_orgs)
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
      return 0 if a == 0 || b == 0 || a == nil ||  b == nil
      (a.to_f / b).round(2)
    end

  end
end
