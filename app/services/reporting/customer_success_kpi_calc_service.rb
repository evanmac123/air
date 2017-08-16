module Reporting
  class CustomerSuccessKpiCalcService
    attr_accessor :curr_interval_start, :curr_interval_end, :interval

    PAID_CLIENTS_DELIGHTED_TREND = 75029
    MONTHLY = "monthly"
    WEEKLY = "weekly"

    def initialize(from_date, to_date, interval)
      @from_date =  from_date
      @to_date =  to_date
      @interval = interval
      @curr_interval_start = @from_date
      setup_current_interval
      get_data
    end

    def tile_emails_for_report
      TilesDigest.paid.where(sent_at: @from_date..@to_date)
    end

    def get_tile_completion_rate
      @tile_completion_rate = tile_emails_for_report.tile_completion_rate
    end

    def tile_completion_rate
      @tile_completion_rate
    end

    def get_tile_view_rate
      @tile_view_rate = tile_emails_for_report.tile_view_rate
    end

    def tile_view_rate
      @tile_view_rate
    end

    def get_tiles_delivered_count
      @tiles_delivered_count = tile_emails_for_report.joins(:tiles_digest_tiles).count
    end

    def tiles_delivered_count
      @tiles_delivered_count
    end

    def get_paid_net_promoter_score
      @nps = Integrations::NetPromoterScore.get_metrics({ until: @curr_interval_start.to_time.to_i, trend: PAID_CLIENTS_DELIGHTED_TREND })
    end

    def paid_net_promoter_score
      @nps
    end

    def get_total_paid_orgs
      @total_paid_orgs = Organization.joins(:demos).where(demos: { is_paid: true }).uniq.count
    end

    def total_paid_orgs
      @total_paid_orgs
    end

    def get_total_paid_client_admins
      @total_paid_client_admins = User.joins(:demo).where(demo: { id: @demo_ids } ).where(is_client_admin: true).count
    end

    def total_paid_client_admins
      @total_paid_client_admins
    end

    def get_org_unique_activity_sessions
      @org_unique_activity_sessions = Reporting::Mixpanel::OrganizationWithUniqueActivitySessions.new(opts)
    end

    def org_unique_activity_sessions
      @org_unique_activity_sessions.get_count(@curr_interval_key)
    end

    def percent_engaged_organizations
      calc_percent(org_unique_activity_sessions, total_paid_orgs)
    end

    def get_client_admin_unique_activity_sessions
      @client_admin_unique_activity_sessions = Reporting::Mixpanel::ClientAdminWithUniqueActivitySessions.new(opts)
    end

    def client_admin_unique_activity_sessions
      @client_admin_unique_activity_sessions.get_count(@curr_interval_key)
    end

    def get_total_client_admin_activity_sessions
      @total_client_admin_activity_sessions = Reporting::Mixpanel::TotalClientAdminActivitySessions.new(opts)
    end

    def total_client_admin_activity_sessions
      @total_client_admin_activity_sessions.get_count(@curr_interval_key)
    end

    def percent_engaged_client_admin
      calc_percent(client_admin_unique_activity_sessions, total_paid_client_admins)
    end

    def activity_sessions_per_client_admin
      calc_avg(total_client_admin_activity_sessions, client_admin_unique_activity_sessions)
    end

    def get_unique_client_admin_with_viewed_tiles_in_explore
      @unique_client_admin_with_viewed_tiles_in_explore =Reporting::Mixpanel::ClientAdminWithUniqueExploreTileViews.new(opts)
    end

    def unique_client_admin_with_viewed_tiles_in_explore
      @unique_client_admin_with_viewed_tiles_in_explore.get_count(@curr_interval_key)
    end

    def get_unique_organizations_with_viewed_tiles_in_explore
      @unique_organizations_with_viewed_tiles_in_explore =Reporting::Mixpanel::UniqueOrganizationsWithViewedTiles.new(opts)
    end

    def unique_organizations_with_viewed_tiles_in_explore
      @unique_organizations_with_viewed_tiles_in_explore.get_count(@curr_interval_key)
    end

    def get_total_tiles_viewed_in_explore
      @total_tiles_viewed_in_explore = Reporting::Mixpanel::TotalTilesViewedInExplore.new(opts)
    end

    def total_tiles_viewed_in_explore
      @total_tiles_viewed_in_explore.get_count(@curr_interval_key)
    end

    def tiles_viewed_per_paid_client_admin
      calc_avg(total_tiles_viewed_in_explore, unique_client_admin_with_viewed_tiles_in_explore)
    end

    def get_tiles_added_by_paid_client_admins
      @tiles_added_by_paid_client_admins = Reporting::Mixpanel::TotalTilesAddedByPaidClientAdmin.new(opts)
    end

    def total_tiles_added
      @tiles_added_by_paid_client_admins.sum(@curr_interval_key)
    end

    def total_tiles_added_from_copy
      @tiles_added_by_paid_client_admins.get_count_by_segment("Explore Page", @curr_interval_key)
    end

    def total_tiles_added_from_scratch
       @tiles_added_by_paid_client_admins.get_count_by_segment("Self Created", @curr_interval_key)
    end

    def get_orgs_that_added_tiles
      @orgs_that_added_tiles = Reporting::Mixpanel::UniqueOrganizationsThatAddedTiles.new(opts)
    end

    def orgs_that_added_tiles
      @orgs_that_added_tiles.get_count(@curr_interval_key)
    end

    def percent_of_orgs_that_added_tiles
      calc_percent(orgs_that_added_tiles, total_paid_orgs)
    end

    def percent_of_tiles_added_from_copy
      calc_percent(total_tiles_added_from_copy, total_tiles_added)
    end

    def percent_of_tiles_added_created_from_scratch
      calc_percent(total_tiles_added_from_scratch, total_tiles_added)
    end

    def get_unique_orgs_that_copied_tiles
      @unique_orgs_that_copied_tiles = Reporting::Mixpanel::UniqueOrganizationsWithCopiedTiles.new(opts)
    end

    def unique_orgs_that_copied_tiles
      @unique_orgs_that_copied_tiles.get_count(@curr_interval_key)
    end

    def get_orgs_that_created_tiles_from_scratch
      @orgs_that_created_tiles_from_scratch = Reporting::Mixpanel::UniqueOrganizationsThatCreatedTilesFromScratch.new(opts)
    end

    def orgs_that_created_tiles_from_scratch
      @orgs_that_created_tiles_from_scratch.get_count(@curr_interval_key)
    end

    def percent_of_orgs_that_viewed_tiles
      calc_percent(unique_organizations_with_viewed_tiles_in_explore, total_paid_orgs)
    end

    def average_tiles_copied_per_org_that_copied
      calc_avg(total_tiles_added_from_copy, unique_orgs_that_copied_tiles)
    end

    def average_tiles_created_from_scratch_per_org_that_created
      calc_avg(total_tiles_added_from_scratch, orgs_that_created_tiles_from_scratch)
    end

    def percent_of_orgs_that_posted_tiles
      calc_percent(orgs_that_posted_tiles, total_paid_orgs)
    end

    def average_tiles_posted_per_organization_that_posted
      calc_avg(total_tiles_posted, orgs_that_posted_tiles)
    end

    def get_total_tiles_posted
      @total_tiles_posted = Reporting::Mixpanel::TotalTilesPostedByPaidClientAdmin.new(opts)
    end

    def total_tiles_posted
      @total_tiles_posted.get_count(@curr_interval_key)
    end

    def get_orgs_that_posted_tiles
      @orgs_that_posted_tiles = Reporting::Mixpanel::UniqueOrganizationsWithPostedTiles.new(opts)
    end

    def orgs_that_posted_tiles
      @orgs_that_posted_tiles.get_count(@curr_interval_key)
    end

    def percent_orgs_that_copied_tiles
      calc_percent(unique_orgs_that_copied_tiles, total_paid_orgs)
    end

    def get_data
      @demo_ids = Demo.paid.pluck(:id)

      get_paid_net_promoter_score
      get_total_paid_client_admins
      get_total_paid_orgs
      get_org_unique_activity_sessions
      get_client_admin_unique_activity_sessions
      get_total_client_admin_activity_sessions
      get_unique_client_admin_with_viewed_tiles_in_explore
      get_unique_organizations_with_viewed_tiles_in_explore
      get_total_tiles_viewed_in_explore
      get_orgs_that_added_tiles
      get_tiles_added_by_paid_client_admins
      get_unique_orgs_that_copied_tiles
      get_orgs_that_created_tiles_from_scratch
      get_orgs_that_posted_tiles
      get_total_tiles_posted
      get_tile_completion_rate
      get_tiles_delivered_count
      get_tile_view_rate
    end

    #----------Utility Methods

    def advance_interval
      if @interval == WEEKLY
        @curr_interval_start =   @curr_interval_start.advance(weeks:1)
      else
        @curr_interval_start =  @curr_interval_start.advance(months:1)
      end
      setup_current_interval
    end

    private

    def setup_current_interval
      @curr_interval_end = end_interval(@curr_interval_start)
      @curr_interval_key = format_date(@curr_interval_start)
    end

    def end_interval s
      @interval == WEEKLY ? s.end_of_week : s.end_of_month
    end

    def unit
      @interval == WEEKLY ? "week" : "month"
    end

    def format_date date
      date.strftime("%Y-%m-%d")
    end

    def opts
      { from_date: @from_date, to_date: @to_date, unit: unit }
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
