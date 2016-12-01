module Reporting
  class CustomerSuccessKpiBuilder
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


    def build_week
      kpi = CustomerSuccessKpi.new

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

      #kpi.percent_retained_post_activation_30_days =
      #kpi.percent_retained_post_activation_60_days =
      #kpi.percent_retained_post_activation_120_days =
      #kpi.average_tile_creation_time =


      #kpi.percent_joined_current =
      #kpi.percent_joined_30_days =
      #kpi.percent_joined_60_days =
      #kpi.percent_joined_120_days =

      kpi.save

    end



    def paid_net_promoter_score
      @nps ||= Integrations::NetPromoterScore.get_metrics({ trend: PAID_CLIENTS_DELIGHTED_TREND })
    end

    def total_paid_orgs
      @total_paid_orgs = Organization.joins(:boards).where(demos: { id: demo_ids }).uniq.count
    end

    def total_paid_client_admins
      @total_paid_client_admins = User.joins(:demo).where(demo: { id: demo_ids } ).where(is_client_admin: true).count
    end

    def org_unique_activity_sessions(time_unit)
      opts = date_opts_for_mixpanel(time_unit)
      @org_unique_activity_sessions = Reporting::Mixpanel::OrganizationWithUniqueActivitySessions.new(opts).values.count
    end

    def client_admin_unique_activity_sessions(time_unit)
      opts = date_opts_for_mixpanel(time_unit)
      @client_admin_unique_activity_sessions = Reporting::Mixpanel::ClientAdminWithUniqueActivitySessions.new(opts).values.count
    end

    def total_client_admin_activity_sessions(time_unit)
      opts = date_opts_for_mixpanel(time_unit)
      @total_client_admin_activity_sessions = Reporting::Mixpanel::TotalClientAdminActivitySessions.new(opts).values.first.values.sum
    end

    def unique_orgs_that_copied_tiles(time_unit)
      opts = date_opts_for_mixpanel(time_unit)
      @unique_orgs_that_copied_tiles = Reporting::Mixpanel::UniqueOrganizationsWithCopiedTiles.new(opts).values.count
    end

    def avg_times_through_funnel(time_unit)
      opts = date_opts_for_mixpanel(time_unit)
      @time_through_funnel = Reporting::Mixpanel::TileCreationFunnel.new(opts).avg_times_through_funnel
    end

    def retention_post_activation
      @retention ||= Report::Mixpanel::UniqueActivitySessionAfterTimePeriodInDays.new(opts)
    end

    def percent_orgs_that_copied_tiles
      calc_percent(@unique_orgs_that_copied_tiles, @total_paid_orgs)
    end

    def total_tiles_copied(time_unit)
      opts = date_opts_for_mixpanel(time_unit)
      @total_tiles_copied = Reporting::Mixpanel::TotalTilesCopied.new(opts).values.first.values.sum
    end

    def average_tiles_copied_per_org_that_copied
      calc_avg(@total_tiles_copied, @unique_orgs_that_copied_tiles)
    end

    def orgs_that_posted_tiles(time_unit)
      opts = date_opts_for_mixpanel(time_unit)
      @orgs_that_posted_tiles = Reporting::Mixpanel::UniqueOrganizationsWithPostedTiles.new(opts).values.count
    end

    def percent_of_orgs_that_posted_tiles
      calc_percent(@orgs_that_posted_tiles, @total_paid_orgs)
    end

    def total_tiles_posted(time_unit)
      opts = date_opts_for_mixpanel(time_unit)
      @total_tiles_posted = Reporting::Mixpanel::TotalTilesPostedByPaidClientAdmin.new(opts).values.first.values.sum
    end

    def average_tiles_posted_per_organization_that_posted
      calc_avg(@total_tiles_posted, @orgs_that_posted_tiles)
    end

    def percent_engaged_organizations
      calc_percent(@org_unique_activity_sessions, @total_paid_orgs)
    end

    def percent_engaged_client_admin
      calc_percent(@client_admin_unique_activity_sessions, @total_paid_client_admins)
    end

    def activity_sessions_per_client_admin
      calc_avg(@total_client_admin_activity_sessions, @total_paid_client_admins)
    end
    def month
      Date.today.strftime("%m/%y")
    end

    def week
      (Date.today.end_of_week + 1.day).strftime("%m/%d/%y")
    end

    def date_opts_for_mixpanel(time_unit)
      if time_unit == :by_week
        date = Date.today
        { from_date: date.beginning_of_week, to_date: date }
      elsif time_unit == :by_month
        date = Date.today
        { from_date: date.beginning_of_month, to_date: date }
      end
    end

    def calc_percent(a, b)
      return 0 if b == 0
      ((a.to_f / b) * 100).round(2)
    end

    def calc_avg(a, b)
      return 0 if b == 0
      (a.to_f / b).round(2)
    end


    related to users joined

    #def set_all_percent_joined!
    #[30, 60, 120, "current"].each { |days_since_launch|
    #set_percent_joined(days_since_launch)
    #}
    #end

    #def set_percent_joined(days_since_launch)
    #if days_since_launch == "current"
    #set_current_percent
    #else
    #set_percent_by_days_since_launch(days_since_launch)
    #end
    #end

    #def get_percent_joined
    #["current", "30", "60", "120"].inject({}) do |hash, key|
    #data = $redis.hgetall("reporting:client_kpis:percent_joined:#{key}")

    #hash[key] = data["percent"].to_f * 100
    #hash
    #end
    #end

    #def calculate_percent_joined_for_key(percent_hash, demo_percent)
    #total = adjust_current_percent_by_count(percent_hash) + demo_percent
    #population = percent_hash["count"].to_i + 1

    #(total / population).round(2)
    #end

    #def set_current_percent
    #scope = User.select([:id, :accepted_invitation_at]).joins(:demo).where(demo: { is_paid: true } )

    #joined_users = scope.where(User.arel_table[:accepted_invitation_at].not_eq(nil))

    #percent = (joined_users.count.to_f / scope.count).round(2)

    #$redis.hmset("reporting:client_kpis:percent_joined:current", "percent", percent, "count", scope.count)
    #end

    #def set_percent_by_days_since_launch(days_since_launch)
    #date = Date.today - days_since_launch.days
    #scope = demos.includes(:users).where(launch_date: date)
    #key = days_since_launch

    #scope.each { |demo|
    #percent_hash = $redis.hgetall("reporting:client_kpis:percent_joined:#{key}")

    #demo_percent = calculate_percent_joined_for_demo(demo)
    #new_percent = calculate_percent_joined_for_key(percent_hash, demo_percent)

    #$redis.hmset("reporting:client_kpis:percent_joined:#{key}", "percent", new_percent, "count", percent_hash["count"].to_i + 1)
    #$redis.hset("reporting:client_kpis:percent_joined_by_demo:#{demo.id}", key, demo_percent)
    #}
    #end


    #def adjust_current_percent_by_count(percent_hash)
    #percent_hash["percent"].to_i * percent_hash["count"].to_i
    #end

    #def calculate_percent_joined_for_demo(demo)
    #(joined_users_count(demo) / total_users_count(demo)).round(2)
    #end

    #def total_users_count(demo)
    #demo.users.count
    #end

    #def joined_users_count(demo)
    #demo.users.where(User.arel_table[:accepted_invitation_at].not_eq(nil)).count.to_f
    #end



  end
end
