module Reporting
  class CustomerSuccessKpiCalcService
    attr_accessor :start_interval, :sdate, :edate

    def initialize(sdate, edate, interval)
      @sdate =  sdate
      @edate =  edate
      @interval = interval
      @start_interval_date = @interval == "weekly" ? sdate.beginning_of_week : sdate.beginning_of_month
      @start_interval = @start_interval_date.strftime("%Y-%m-%d")
      get_data
    end

    def paid_net_promoter_score
      @nps = Integrations::NetPromoterScore.get_metrics({ trend: PAID_CLIENTS_DELIGHTED_TREND })
    end

    def total_paid_orgs
      @total_paid_orgs = Organization.joins(:boards).where(demos: { id: @demo_ids }).uniq.count
    end

    def total_paid_client_admins
      @total_paid_client_admins = User.joins(:demo).where(demo: { id: @demo_ids } ).where(is_client_admin: true).count
    end


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


    def unique_client_admin_with_viewed_tiles_in_explore
      @unique_client_admin_with_viewed_tiles_in_explore =Reporting::Mixpanel::ClientAdminWithUniqueExploreTileViews.new(opts).get_count(@start_interval)
    end

    def unique_organizations_with_viewed_tiles_in_explore
      @unique_organizations_with_viewed_tiles_in_explore =Reporting::Mixpanel::UniqueOrganizationsWithViewedTiles.new(opts).get_count(@start_interval)
    end

    def total_tiles_viewed_in_explore
      @total_tiles_viewed_in_explore = Reporting::Mixpanel::TotalTilesViewedInExplore.new(opts).get_count(@start_interval)
    end

    def tiles_viewed_per_paid_client_admin
      calc_avg(@total_tiles_viewed_in_explore, @unique_client_admin_with_viewed_tiles_in_explore)
    end


    def tiles_added_by_paid_client_admins
      @tiles_added = Reporting::Mixpanel::TotalTilesAddedByPaidClientAdmin.new(opts)
      @total_tiles_added = @tiles_added.sum(@start_interval)
    end

    def total_tiles_added
      @total_tiles_added
    end 

    def total_tiles_added_from_copy
      @total_tiles_added_from_copy = @tiles_added.get_count_by_segment("Explore Page", @start_interval)
    end

    def total_tiles_added_from_scratch
      @tiles_created_from_scratch  = @tiles_added.get_count_by_segment("Self Created", @start_interval)
    end

    def orgs_that_added_tiles
      @orgs_that_added_tiles = Reporting::Mixpanel::UniqueOrganizationsThatAddedTiles.new(opts).get_count(@start_interval)
    end

    def percent_of_orgs_that_added_tiles
      calc_percent(@orgs_that_added_tiles, @total_paid_orgs)
    end

    def percent_of_tiles_added_from_copy
      calc_percent(total_tiles_added_from_copy, @total_tiles_added)
    end

    def percent_of_tiles_added_created_from_scratch
      calc_percent(total_tiles_added_from_scratch,@total_tiles_added)
    end

    def unique_orgs_that_copied_tiles
      @unique_orgs_that_copied_tiles = Reporting::Mixpanel::UniqueOrganizationsWithCopiedTiles.new(opts).get_count(@start_interval)
    end

    def orgs_that_created_tiles_from_scratch
      @orgs_that_created_tiles_from_scratch = Reporting::Mixpanel::UniqueOrganizationsThatCreatedTilesFromScratch.new(opts).get_count(@start_interval)
    end

    def percent_of_orgs_that_viewed_tiles
      calc_percent(@unique_organizations_with_viewed_tiles_in_explore, @total_paid_orgs)
    end


    def average_tiles_copied_per_org_that_copied
      calc_avg(@total_tiles_added_from_copy, @unique_orgs_that_copied_tiles)
    end

    def average_tiles_created_from_scratch_per_org_that_created
      calc_avg(@tiles_created_from_scratch, @orgs_that_created_tiles_from_scratch)
    end


    def avg_tile_creation_time
      @avg_tile_creation_time = Reporting::Mixpanel::TileCreationFunnel.new(opts).get_avg_time(@start_interval)
    end

    def retention
      @retention = Reporting::Mixpanel::UniqueActivitySessionAfterTimePeriodInDays.new(opts)
    end

    def retention_by_days days
      #TODO fix implementation
      return nil
      #retention.get_count_by_segment(days)
    end

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

    def total_tiles_posted
      @total_tiles_posted = Reporting::Mixpanel::TotalTilesPostedByPaidClientAdmin.new(opts).get_count(@start_interval)
    end

    def orgs_that_posted_tiles
      @orgs_that_posted_tiles = Reporting::Mixpanel::UniqueOrganizationsWithPostedTiles.new(opts).get_count(@start_interval)
    end

    def percent_orgs_that_copied_tiles
      calc_percent(@unique_orgs_that_copied_tiles, @total_paid_orgs)
    end

    def get_data
      @demo_ids = Demo.paid.pluck(:id) 
      total_paid_orgs
      org_unique_activity_sessions
      client_admin_unique_activity_sessions
      total_client_admin_activity_sessions
      unique_client_admin_with_viewed_tiles_in_explore
      unique_organizations_with_viewed_tiles_in_explore
      total_tiles_viewed_in_explore
      orgs_that_added_tiles
      tiles_added_by_paid_client_admins
      unique_orgs_that_copied_tiles
      orgs_that_created_tiles_from_scratch
      orgs_that_posted_tiles
      total_tiles_posted
    end

    #----------Utility Methods

    def advance_interval
      @start_interval_date = interval == WEEKLY ? @start_interval_date.advance(weeks:1) : @start_interval_date.adance(months:1)
    end

    private 

    def opts
      {from_date: sdate, to_date: edate}
    end

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

