module Reporting
  class AirboTotals
    class << self
      def set_total_paid_organizations
        count = Organization.joins(:boards).where(demos: { id: demo_ids }).count

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
        count = User.joins(:demo).where(demo: { id: demo_ids } ).where(is_client_admin: true).count

        $redis.hset("reporting:airbo:total_paid_client_admins:months", month, count)
        $redis.hset("reporting:airbo:total_paid_client_amdins:weeks", week, count)
      end

      def get_total_paid_client_admins_by_month
        $redis.hgetall("reporting:airbo:total_paid_client_admins:months")
      end

      def get_total_paid_client_admins_by_week
        $redis.hgetall("reporting:airbo:total_paid_client_amdins:weeks")
      end

      def set_percent_of_eligible_population_joined(days_since_launch)
        if days_since_launch == "current"
          set_current_percent
        else
          set_percent_by_days_since_launch(days_since_launch)
        end
      end

      def get_percent_of_eligible_population_joined
        ["current", "30", "60", "120"].inject({}) do |hash, key|
          data = $redis.hgetall("reporting:airbo:percent_of_eligible_population_joined:#{key}")

          hash[key] = data["percent"].to_f * 100
          hash
        end
      end

      private

        def demos
          @demos || Demo.paid
        end

        def demo_ids
          @demo_ids || demos.pluck(:id)
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

        def calculate_percent_population_joined_for_demo(demo)
          (joined_users_count(demo) / total_users_count(demo)).round(2)
        end

        def calculate_percent_population_joined_for_key(percent_hash, demo_percent)

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
            percent_hash = $redis.hgetall("reporting:airbo:percent_of_eligible_population_joined:#{key}")

            demo_percent = calculate_percent_population_joined_for_demo(demo)
            new_percent = calculate_percent_population_joined_for_key(percent_hash, demo_percent)

            $redis.hmset("reporting:airbo:percent_of_eligible_population_joined:#{key}", "percent", new_percent, "count", percent_hash["count"].to_i + 1)
            $redis.hset("reporting:airbo:percent_of_eligible_population_joined_by_demo:#{demo.id}", key, demo_percent)
          }
        end

        def set_current_percent
          scope = User.select([:id, :accepted_invitation_at]).joins(:demo).where(demo: { is_paid: true } )

          joined_users = scope.where(User.arel_table[:accepted_invitation_at].not_eq(nil))

          percent = (joined_users.count.to_f / scope.count).round(2)

          $redis.hmset("reporting:airbo:percent_of_eligible_population_joined:current", "percent", percent, "count", scope.count)
        end

        def rake_methods
          [30, 60, 120, "current"].each { |key|
            $redis.hmset("reporting:airbo:percent_of_eligible_population_joined:#{key}", "percent", 0, "count", 0)
          }
        end
    end
  end
end
