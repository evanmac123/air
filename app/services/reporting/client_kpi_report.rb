module Reporting
  class ClientKPIReport

    def get_data_by_date sdate, edate
      build_data_set(row_set(raw_data(sdate, edate)))
    end

    def build_data_set row_data 
      container = HashWithIndifferentAccess.new(kpi_fields)
      container.each do|field, sub_hash|
        sub_hash[:values] = row_data[field]
      end

      add_group_separators(container)
      container.merge!(aliased_kpis(container))
      container
    end

    def aliased_kpis container
      {}
    end

    def default_date_range
      edate = Date.today.beginning_of_week
      sdate = edate.advance(weeks: -5)
      [sdate, edate]
    end

    def row_set res
      fields = res.map(&:keys).flatten.uniq
      values = res.map(&:values).transpose
      Hash[fields.zip(values)]
    end

    def raw_data sdate, edate
      CustSuccessKpi.normalized_by_start_and_end sdate, edate 
    end

    def query_select_fields
      kpi_fields.keys.join(",")
    end 

    def add_group_separators(container)
      group_separators.each do |key, label|
        add_group_separator(container, key, label)
      end
      container
    end

    def add_group_separator container, key, label
      container[key]= {
        label: label,
        type:"",
        indent: 0,
        values: []
      }
      container
    end

    def group_separators 
      { }
    end

    def sections
      {

        "Overall Engagement" =>  [
          "paid_net_promoter_score",
          "paid_net_promoter_score_response_count",
          "percent_engaged_organizations",
          "unique_org_with_activity_sessions",
          "total_paid_orgs",
          "percent_engaged_client_admin",
          "unique_client_admin_with_activity_sessions",
          "total_paid_client_admins",
          "total_paid_client_admin_activity_sessions",
          "activity_sessions_per_client_admin"
        ],
        "Planning" => [
        ],

        "Creation" => [
          "percent_orgs_that_copied_tiles",
          "total_tiles_copied",
          "unique_orgs_that_copied_tiles",
          "average_tiles_copied_per_org_that_copied"
        ],
        "Content" => [
          "orgs_that_posted_tiles",
          "percent_of_orgs_that_posted_tiles",
          "total_tiles_posted",
          "average_tiles_posted_per_organization_that_posted",
          "average_tile_creation_time"
        ],
        "Engagement" => [
          "percent_joined_current",
          "percent_joined_30_days",
          "percent_joined_60_days",
          "percent_joined_120_days",
          "percent_retained_post_activation_30_days",
          "percent_retained_post_activation_60_days",
          "percent_retained_post_activation_120_days"
        ],

      }
    end


    def kpi_fields
      {

        "report_date" => {
          label: "Date",
          type: "date",
          hint: "",
          indent: 0
        },
        "paid_net_promoter_score" => {
          label: "Net Promoter Score (NPS)",
          type: "num",
          hint: "Rolling 90 days",
          indent: 0,
        },
        "paid_net_promoter_score_response_count" => {
          label: "Responses",
          type: "num",
          hint: "",
          indent: 1,
        },
        "percent_engaged_organizations" =>{
          label: "Customer Engagement",
          type: "pct",
          hint: "",
          indent: 0,
        },
        "unique_org_with_activity_sessions" =>{
          label: "Engaged ",
          type: "num",
          hint: "Unique Organizations with One or More Activity Session",
          indent: 1,
        },
        "total_paid_orgs" =>{
          label: "Customers",
          type: "num",
          hint: "",
          indent: 1,
        },
        "percent_engaged_client_admin" =>{
          label: "Client Admin Engagement",
          type: "pct",
          hint: "",
          indent: 0,
        },
        "unique_client_admin_with_activity_sessions" =>{
          label: "Engaged",
          type: "num",
          hint: "Unique Paid Client Admins with One or More Activity Session",
          indent: 1,
        },
        "total_paid_client_admins" =>{
          label: "Client Admins" ,
          type: "num",
          hint: "",
          indent: 1,
        },

        "total_paid_client_admin_activity_sessions" =>{
          label: "Total Activity Sessions",
          type: "num",
          hint: "",
          indent: 0,
        },
        "activity_sessions_per_client_admin" =>{
          label: "Per Engaged Client Admin",
          type: "num",
          hint: "Activity Sessions Per Engaged Client Admin",
          indent: 1,
        },
        "percent_orgs_that_copied_tiles" =>{
          label: "Copied",
          type: "pct",
          hint: "% of New Tiles that were copied from Explore",
          indent: 1,
        },
        "total_tiles_copied" =>{
          label: "Tiles Copied",
          type: "num",
          hint: "",
          indent: 0,
        },
        "unique_orgs_that_copied_tiles" =>{
          label: "Customers",
          type: "num",
          hint: "",
          indent: 1,
        },
        "average_tiles_copied_per_org_that_copied" =>{
          label: "Average",
          type: "num",
          hint: "Avg Tiles Copied Per Org that Copied",
          indent: 1,
        },
        "orgs_that_posted_tiles" =>{
          label: "Orgs That Posted Tiles",
          type: "num",
          hint: "",
          indent: 0,
        },
        "percent_of_orgs_that_posted_tiles" =>{
          label: "% of Orgs That Posted Tiles",
          type: "pct",
          hint: "",
          indent: 0,
        },
        "total_tiles_posted" =>{
          label: "Total Tiles Posted",
          type: "num",
          hint: "",
          indent: 0,
        },
        "average_tiles_posted_per_organization_that_posted" =>{
          label: "Average Tiles Posted Per Organization That Posted Tiles",
          type: "num",
          hint: "",
          indent: 0,
        },
        "average_tile_creation_time" =>{
          label: "Average Tiles Creation Time",
          type: "num",
          hint: "",
          indent: 0,
        },
 "percent_joined_current" =>{
          label: "% of eligible population joined",
          type: "pct",
          hint: "",
          indent: 0,
        },
        "percent_joined_30_days" =>{
          label: "30 Days",
          type: "pct",
          hint: "",
          indent: 0,
        },
        "percent_joined_60_days" =>{
          label: "60 Days",
          type: "pct",
          hint: "",
          indent: 0,
        },
        "percent_joined_120_days" =>{
          label: "120 Days",
          type: "pct",
          hint: "",
          indent: 0,
        },
        "percent_retained_post_activation_30_days" =>{
          label: "30 Days",
          type: "pct",
          hint: "",
          indent: 0,
        },
        "percent_retained_post_activation_60_days" =>{
          label: "60 Days",
          type: "pct",
          hint: "",
          indent: 0,
        },
        "percent_retained_post_activation_120_days" =>{
          label: "120 Days",
          type: "pct",
          hint: "",
          indent: 0,
        },
      }
    end

    private


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
