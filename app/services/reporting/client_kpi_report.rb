module Reporting
  class ClientKPIReport

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
          "net_promoter_score",
          nil,
          "total_paid_orgs",
          "org_unique_activity_sessions",
          "percent_engaged_organizations",
          nil,
          "total_paid_client_admins",
          "client_admin_unique_activity_sessions",
          "percent_engaged_client_admin",
          nil,
          "total_paid_client_admin_activity_sessions",
          "total_paid_client_admins",
          "activity_sessions_per_client_admin"
      ],

      "Engagement" => [
        "percent_joined_current",
        "percent_joined_30_days",
        "percent_joined_60_days",
        "percent_joined_120_days"
      ],

      }
    end

    def run_report(time_unit)
      set_all_percent_joined!
      percent_population_joined = get_percent_joined

      data =
        {
          total_paid_orgs: total_paid_orgs,
          total_paid_client_admins: total_paid_client_admins,
          org_unique_activity_sessions: org_unique_activity_sessions(time_unit),
          client_admin_unique_activity_sessions: client_admin_unique_activity_sessions(time_unit),
          total_paid_client_admin_activity_sessions: total_client_admin_activity_sessions(time_unit),
          activity_sessions_per_client_admin: activity_sessions_per_client_admin,
          percent_engaged_organizations: percent_engaged_organizations,
          percent_engaged_client_admin: percent_engaged_client_admin,
          percent_joined_current: percent_population_joined["current"],
          percent_joined_30_days: percent_population_joined["30"],
          percent_joined_60_days: percent_population_joined["60"],
          percent_joined_120_days: percent_population_joined["120"],
        }

      post_report_to_redis(data.to_json)
    end

    def post_report_to_redis(report_data)
      $redis.hset("reporting:client_kpis:monthly", month, report_data)
      $redis.hset("reporting:client_kpis:weekly", week, report_data)
    end

    private

      def total_paid_orgs
        @total_paid_orgs ||= Organization.joins(:boards).where(demos: { id: demo_ids }).uniq.count
      end

      def total_paid_client_admins
        @total_paid_client_admins ||= User.joins(:demo).where(demo: { id: demo_ids } ).where(is_client_admin: true).count
      end

      def org_unique_activity_sessions(time_unit)
        opts = date_opts_for_mixpanel(time_unit)
        @org_unique_activity_sessions ||= Reporting::Mixpanel::OrganizationWithUniqueActivitySessions.new(opts).values.count
      end

      def client_admin_unique_activity_sessions(time_unit)
        opts = date_opts_for_mixpanel(time_unit)
        @client_admin_unique_activity_sessions ||= Reporting::Mixpanel::ClientAdminWithUniqueActivitySessions.new(opts).values.count
      end

      def total_client_admin_activity_sessions(time_unit)
        opts = date_opts_for_mixpanel(time_unit)
        @total_client_admin_activity_sessions ||= Reporting::Mixpanel::TotalClientAdminActivitySessions.new(opts).values.count
      end

      def percent_engaged_organizations
        (@org_unique_activity_sessions.to_f / @total_paid_orgs) * 100
      end

      def percent_engaged_client_admin
        (@total_client_admin_activity_sessions.to_f / @total_paid_client_admins) * 100
      end

      def activity_sessions_per_client_admin
        (@client_admin_unique_activity_sessions.to_f / @total_paid_client_admins) * 100
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
          date = Date.today.beginning_of_week
          { from_date: date - 1.week, to_date: date }
        elsif time_unit == :by_month
          date = Date.today
          { from_date: date.beginning_of_month, to_date: date }
        end
      end

      def month
        Date.today.strftime("%m/%y")
      end

      def week
        Date.today.beginning_of_week.strftime("%m/%d/%y")
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
