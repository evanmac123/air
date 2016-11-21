module Reporting
  class ClientKPIReport
    PAID_CLIENTS_DELIGHTED_TREND = 75029

    def self.get_weekly_report_data
      report_data = $redis.hgetall("reporting:client_kpis:weekly")

      report_data.each { |date, data|
        report_data[date] = JSON.parse(data)
      }
    end

    def self.run_report()
      ClientKPIReport.new.run_report(:by_week)
      ClientKPIReport.new.run_report(:by_month)
    end

    def self.sections
      {

        "Overall Satisfaction" =>  [
          "paid_net_promoter_score",
          "paid_net_promoter_score_response_count",
          "total_paid_orgs",
          "org_unique_activity_sessions",
          "percent_engaged_organizations",
          "total_paid_client_admins",
          "client_admin_unique_activity_sessions",
          "percent_engaged_client_admin",
          "total_paid_client_admin_activity_sessions",
          "total_paid_client_admins",
          "activity_sessions_per_client_admin"
        ],
        "Planning" => [
          "unique_orgs_that_copied_tiles",
          "percent_orgs_that_copied_tiles",
          "total_tiles_copied",
          "average_tiles_copied_per_org_that_copied"
        ],
        "Content" => [
          "orgs_that_posted_tiles",
          "percent_of_orgs_that_posted_tiles",
          "total_tiles_posted",
          "average_tiles_posted_per_organization_that_posted"
        ],
        "Engagement" => [
          "percent_joined_current",
          "percent_joined_30_days",
          "percent_joined_60_days",
          "percent_joined_120_days"
        ],

      }
    end


    def self.kpi_fields
      {
        "paid_net_promoter_score" => {
          label: "Net Promoter Score (last 90 days)",
          type: "num",
          indent: 0,
        },
        "paid_net_promoter_score_response_count" => {
          label: "Net Promoter Score Response Count",
          type: "num",
          indent: 0,
        },
        "total_paid_orgs" =>{
          label: "Total Paid Organizations",
          type: "num",
          indent: 0,
        },
        "org_unique_activity_sessions" =>{
          label: "Unique Organizations with One or More Activity Session",
          type: "num",
          indent: 0,
        },
        "percent_engaged_organizations" =>{
          label: "% of Engaged Organizations",
          type: "pct",
          indent: 0,
        },
        "total_paid_client_admins" =>{
          label: "Total Paid Client Admins" ,
          type: "num",
          indent: 0,
        },
        "client_admin_unique_activity_sessions" =>{
          label: "Unique Paid Client Admins with One or More Activity Session",
          type: "num",
          indent: 0,
        },
        "percent_engaged_client_admin" =>{
          label: "% of Engaged Paid Client Admins",
          type: "pct",
          indent: 0,
        },
        "total_paid_client_admin_activity_sessions" =>{
          label: "Total Paid Client Admin Activity Sessions",
          type: "num",
          indent: 0,
        },
        "total_paid_client_admins" =>{
          label: "Total Paid Client Admins",
          type: "num",
          indent: 0,
        },
        "activity_sessions_per_client_admin" =>{
          label: "Activity Sessions Per Client Admin",
          type: "num",
          indent: 0,
        },
        "percent_orgs_that_copied_tiles" =>{
          label: "% Orgs that Copied Tiles",
          type: "pct",
          indent: 0,
        },
        "total_tiles_copied" =>{
          label: "Total Tiles Copied",
          type: "num",
          indent: 0,
        },
        "unique_orgs_that_copied_tiles" =>{
          label: "Unique Orgs that Copied Tiles",
          type: "num",
          indent: 0,
        },
        "average_tiles_copied_per_org_that_copied" =>{
          label: "Avg Tiles Copied Per Org that Copied",
          type: "num",
          indent: 0,
        },
        "orgs_that_posted_tiles" =>{
          label: "Orgs That Posted Tiles",
          type: "num",
          indent: 0,
        },
         "percent_of_orgs_that_posted_tiles" =>{
          label: "% of Orgs That Posted Tiles",
          type: "pct",
          indent: 0,
        },
        "total_tiles_posted" =>{
          label: "Total Tiles Posted",
          type: "num",
          indent: 0,
        },
        "average_tiles_posted_per_organization_that_posted" =>{
          label: "Average Tiles Posted Per Organization That Posted Tiles",
          type: "num",
          indent: 0,
        },
        "percent_joined_current" =>{
          label: "% of eligible population joined",
          type: "pct",
          indent: 0,
        },
        "percent_joined_30_days" =>{
          label: "30 Days",
          type: "pct",
          indent: 0,
        },
        "percent_joined_60_days" =>{
          label: "60 Days",
          type: "pct",
          indent: 0,
        },
        "percent_joined_120_days" =>{
          label: "120 Days",
          type: "pct",
          indent: 0,
        }
      }
    end

    def run_report(time_unit)
      set_all_percent_joined!
      percent_population_joined = get_percent_joined

      data =
        {
          paid_net_promoter_score: get_paid_net_promoter_score.nps,
          paid_net_promoter_score_response_count: get_paid_net_promoter_score.response_count,
          total_paid_orgs: total_paid_orgs,
          total_paid_client_admins: total_paid_client_admins,
          org_unique_activity_sessions: org_unique_activity_sessions(time_unit),
          client_admin_unique_activity_sessions: client_admin_unique_activity_sessions(time_unit),
          total_paid_client_admin_activity_sessions: total_client_admin_activity_sessions(time_unit),
          activity_sessions_per_client_admin: activity_sessions_per_client_admin,
          percent_engaged_organizations: percent_engaged_organizations,
          unique_orgs_that_copied_tiles: unique_orgs_that_copied_tiles(time_unit),
          percent_orgs_that_copied_tiles: percent_orgs_that_copied_tiles,
          total_tiles_copied: total_tiles_copied(time_unit),
          average_tiles_copied_per_org_that_copied: average_tiles_copied_per_org_that_copied,
          orgs_that_posted_tiles: orgs_that_posted_tiles(time_unit),
          percent_of_orgs_that_posted_tiles: percent_of_orgs_that_posted_tiles,
          total_tiles_posted: total_tiles_posted(time_unit),
          average_tiles_posted_per_organization_that_posted: average_tiles_posted_per_organization_that_posted,
          percent_engaged_client_admin: percent_engaged_client_admin,
          percent_joined_current: percent_population_joined["current"],
          percent_joined_30_days: percent_population_joined["30"],
          percent_joined_60_days: percent_population_joined["60"],
          percent_joined_120_days: percent_population_joined["120"],
        }

      post_report_to_redis(data.to_json, time_unit)
    end

    def post_report_to_redis(report_data, time_unit)
      if time_unit == :by_week
        $redis.hset("reporting:client_kpis:weekly", week, report_data)
      elsif time_unit == :by_month
        $redis.hset("reporting:client_kpis:monthly", month, report_data)
      end
    end

    private

      def get_paid_net_promoter_score
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

      def calc_percent(a, b)
        return 0 if b == 0
        ((a.to_f / b) * 100).round(2)
      end

      def calc_avg(a, b)
        return 0 if b == 0
        (a.to_f / b).round(2)
      end

      def percent_orgs_that_copied_tiles
        binding.pry
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

      def set_all_percent_joined!
        [30, 60, 120, "current"].each { |days_since_launch|
          set_percent_joined(days_since_launch)
        }
      end

      def set_percent_joined(days_since_launch)
        if days_since_launch == "current"
          set_current_percent
        else
          set_percent_by_days_since_launch(days_since_launch)
        end
      end

      def get_percent_joined
        ["current", "30", "60", "120"].inject({}) do |hash, key|
          data = $redis.hgetall("reporting:client_kpis:percent_joined:#{key}")

          hash[key] = data["percent"].to_f * 100
          hash
        end
      end

      def demos
        @demos || Demo.paid
      end

      def demo_ids
        @demo_ids || demos.pluck(:id)
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

      def month
        Date.today.strftime("%m/%y")
      end

      def week
        (Date.today.end_of_week + 1.day).strftime("%m/%d/%y")
      end

      def adjust_current_percent_by_count(percent_hash)
        percent_hash["percent"].to_i * percent_hash["count"].to_i
      end

      def calculate_percent_joined_for_demo(demo)
        (joined_users_count(demo) / total_users_count(demo)).round(2)
      end

      def calculate_percent_joined_for_key(percent_hash, demo_percent)

        total = adjust_current_percent_by_count(percent_hash) + demo_percent
        population = percent_hash["count"].to_i + 1

        (total / population).round(2)
      end

      def total_users_count(demo)
        demo.users.count
      end

      def joined_users_count(demo)
        demo.users.where(User.arel_table[:accepted_invitation_at].not_eq(nil)).count.to_f
      end

      def set_percent_by_days_since_launch(days_since_launch)
        date = Date.today - days_since_launch.days
        scope = demos.includes(:users).where(launch_date: date)
        key = days_since_launch

        scope.each { |demo|
          percent_hash = $redis.hgetall("reporting:client_kpis:percent_joined:#{key}")

          demo_percent = calculate_percent_joined_for_demo(demo)
          new_percent = calculate_percent_joined_for_key(percent_hash, demo_percent)

          $redis.hmset("reporting:client_kpis:percent_joined:#{key}", "percent", new_percent, "count", percent_hash["count"].to_i + 1)
          $redis.hset("reporting:client_kpis:percent_joined_by_demo:#{demo.id}", key, demo_percent)
        }
      end

      def set_current_percent
        scope = User.select([:id, :accepted_invitation_at]).joins(:demo).where(demo: { is_paid: true } )

        joined_users = scope.where(User.arel_table[:accepted_invitation_at].not_eq(nil))

        percent = (joined_users.count.to_f / scope.count).round(2)

        $redis.hmset("reporting:client_kpis:percent_joined:current", "percent", percent, "count", scope.count)
      end
  end
end
