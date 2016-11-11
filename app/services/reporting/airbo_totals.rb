module Reporting
  class AirboTotals
    class << self
      def set_total_paid_organizations
        count = demos.count

        $redis.hset("reporting:airbo:total_paid_orgs:months", month, count)

        $redis.hset("reporting:airbo:total_paid_orgs:weeks", week, count)
      end

      def get_total_paid_organizations_by_month
        $redis.hgetall("reporting:airbo:total_paid_orgs:months")
      end

      def get_total_paid_organizations_by_week
        $redis.hgetall("reporting:airbo:total_paid_orgs:weeks")
      end

      def set_total_paid_client_admins
        count = User.joins(:demo).where(demo: { id: demos.pluck(:id) } ).where(is_client_admin: true).count

        $redis.hset("reporting:airbo:total_paid_client_admins:months", month, count)

        $redis.hset("reporting:airbo:total_paid_client_amdins:weeks", week, count)
      end

      def get_total_paid_client_admins_by_month
        $redis.hgetall("reporting:airbo:total_paid_client_admins:months")
      end

      def get_total_paid_client_admins_by_week
        $redis.hgetall("reporting:airbo:total_paid_client_amdins:weeks")
      end

      def set_percent_of_eligible_population_joined(days_since_launch = nil)
        if days_since_launch
          set_percent_by_days_since_launch(days_since_launch)
        else
          set_current_percent
        end
      end

      private

        def demos
          @demos || Demo.paid
        end

        def month
          Date.today.strftime("%B %Y")
        end

        def week
          Date.today.beginning_of_week.strftime("%m/%d/%Y")
        end

        def calculate_percent_population_joined_for_demo(demo)
          (demo.users.where(User.arel_table[:accepted_invitation_at].not_eq(nil)).count.to_f / demo.users.count).round(2)
        end

        def set_percent_by_days_since_launch(days_since_launch)
          date = Date.today - days_since_launch.days
          scope = demos.includes(:users).where(launch_date: date)

          scope.each { |demo|
            key = days_since_launch || "current"
            percent_hash = $redis.hgetall("reporting:airbo:percent_of_eligible_population_joined:#{key}")

            demo_percent = calculate_percent_population_joined_for_demo(demo)

            new_percent = (((percent_hash[:percent] * percent_hash[:count]) + demo_percent) / (percent_hash[:count] + 1)).round(2)
            $redis.hmset("reporting:airbo:percent_of_eligible_population_joined:#{key}", "percent", new_percent, "count", percent_hash[:count] + 1)

            $redis.hset("reporting:airbo:percent_of_eligible_population_joined:#{demo.id}", key, demo_percent)
          }
        end

        def set_current_percent
          scope = User.select([:id, :accepted_invitation_at]).joins(:demo).where(demo: { is_paid: true } )

          joined_users = scope.where(User.arel_table[:accepted_invitation_at].not_eq(nil))

          percent = (joined_users.count.to_f / scope.count).round(2)

          $redis.hset("reporting:airbo:percent_of_eligible_population_joined", "current", percent)
        end
    end
  end
end
