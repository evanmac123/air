module Reporting
  class ClientKPIReport <KpiReportingBase

    #FIXME move this constant to common location to remove duplication
    PAID_CLIENTS_DELIGHTED_TREND = 75029

    def default_date_range
      edate = Date.today.beginning_of_week
      sdate = edate.advance(weeks: -5)
      [sdate, edate]
    end

    def db_fields
      CustSuccessKpi.select(query_select_fields)
    end

    def curr_nps
      curr_nps_data.nps
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
          "percent_paid_orgs_view_tile_in_explore",
          "unique_orgs_that_viewed_tiles_in_explore",
          "total_tiles_viewed_in_explore_by_paid_orgs",
          "paid_client_admins_who_viewed_tiles_in_explore",
          "tiles_viewed_per_paid_client_admin"
        ],
        "Creation" => [
          "percent_orgs_that_added_tiles",
          "total_tiles_added_by_paid_client_admin",
          "unique_orgs_that_added_tiles",

          "percent_of_added_tiles_from_copy",
          "percent_of_added_tiles_from_scratch",

          "total_tiles_added_from_copy_by_paid_client_admin",
          "unique_orgs_that_copied_tiles",
          "average_tiles_copied_per_org_that_copied",

          "tiles_created_from_scratch",
          "orgs_that_created_tiles_from_scratch",
          "average_tiles_created_from_scratch_per_org_that_created",
          "average_tile_creation_time"
        ],

        #"Engagement" => [
          #"percent_joined_current",
          #"percent_joined_30_days",
          #"percent_joined_60_days",
          #"percent_joined_120_days",
          #"percent_retained_post_activation_30_days",
          #"percent_retained_post_activation_60_days",
          #"percent_retained_post_activation_120_days"
        #],

      }
    end


    def kpi_fields
      {

        "from_date" => {
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
          css: " kpi-tooltip"
        },
        "paid_net_promoter_score_response_count" => {
          label: "Responses",
          type: "num",
          hint: "",
          indent: 1,
        },
        "percent_engaged_organizations" =>{
          label: "Customer Engagement",
          type: "pct 0",
          hint: "",
          indent: 0,
          css: ""
        },
        "unique_org_with_activity_sessions" =>{
          label: "Engaged ",
          type: "num",
          hint: "Unique Organizations with One or More Activity Session",
          css: "kpi-tooltip",
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
          type: "pct 0",
          hint: "",
          indent: 0,
          css: ""
        },
        "unique_client_admin_with_activity_sessions" =>{
          label: "Engaged",
          type: "num",
          hint: "Unique Paid Client Admins with One or More Activity Session",
          css: "kpi-tooltip",
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
          css: "kpi-tooltip",
          indent: 1,
        },


        "percent_paid_orgs_view_tile_in_explore" => {
          label: "Explore Engagement",
          type: "pct 0",
          hint: "% of Paid Organizations that viewed a Tile in Airbo Explore",
          indent: 0,
          css: " kpi-tooltip"
        },
        "total_tiles_viewed_in_explore_by_paid_orgs" => {
          label: "Total Tile Views",
          type: "num",
          hint: "Total # of Tiles viewed in Explore by Paid Organizations",
          css: "kpi-tooltip",
          indent: 0
        },
        "paid_client_admins_who_viewed_tiles_in_explore" => {
          label: "Unique Tile Views",
          type: "num",
          hint: "# of client admins that viewed Tiles",
          css: "kpi-tooltip",
          indent: 1
        },
        "tiles_viewed_per_paid_client_admin" => {
          label: "Avg Tile Views",
          type: "num",
          hint: "# of Tile Views per Paid Client Admin",
          css: "kpi-tooltip",
          indent: 1
        },
        "percent_orgs_that_added_tiles" => {
          label: "Tile Creation Engagement",
          type: "pct 0",
          hint: "% of Paid Organizations that added a tile",
          indent: 0,
          css: " kpi-tooltip"
        },
        "total_tiles_added_by_paid_client_admin" => {
          label: "New Tiles Added",
          type: "num",
          hint: "# Total Tiles Added by Paid Client Admins",
          css: "kpi-tooltip",
          indent: 0
        },
        "unique_orgs_that_added_tiles" => {
          label: "Customers",
          type: "num",
          hint: "# of customers that added Tiles",
          css: "kpi-tooltip",
          indent: 1
        },
        "percent_of_added_tiles_from_copy" => {
          label: "Copied",
          type: "pct 0",
          hint: "% of New Tiles that were copied from Explore",
          css: "kpi-tooltip",
          indent: 1
        },
        "percent_of_added_tiles_from_scratch" => {
          label: "Created",
          type: "pct 0",
          hint: "% of New Tiles that were created from scratch",
          css: "kpi-tooltip",
          indent: 1
        },
        "percent_orgs_that_copied_tiles" =>{
          label: "Copied",
          type: "pct 0",
          hint: "% of New Tiles that were copied from Explore",
          css: "kpi-tooltip",
          indent: 1,
        },
        "total_tiles_added_from_copy_by_paid_client_admin" =>{
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
          css: "kpi-tooltip",
          hint: "Avg Tiles Copied Per Org that Copied",
          indent: 1,
        },

        "unique_orgs_that_viewed_tiles_in_explore" =>{
          label: "Customers",
          type: "num",
          css: "kpi-tooltip",
          hint: "Unique organizations engaged in Explore",
          indent: 0,
        },
        "orgs_that_posted_tiles" =>{
          label: "Orgs That Posted Tiles",
          type: "num",
          hint: "",
          indent: 0,
        },
        "percent_of_orgs_that_posted_tiles" =>{
          label: "% of Orgs That Posted Tiles",
          type: "pct 0",
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

        "tiles_created_from_scratch" => {
          label: "Tiles Created",
          type: "num",
          hint: "",
          indent: 0
        },
        "orgs_that_created_tiles_from_scratch" => {
          label: "Customers",
          type: "num",
          hint: "",
          indent: 1
        },
        "average_tiles_created_from_scratch_per_org_that_created" => {
          label: "Average",
          type: "num",
          hint: "",
          indent: 1
        },

        "average_tile_creation_time" =>{
          label: "Speed",
          type: "num",
          hint: "Average tile creation time in seconds",
          indent: 1,
        },

        "percent_joined_current" =>{
          label: "User Activation",
          type: "pct 0",
          hint: "",
          indent: 1,
        },
        "percent_joined_30_days" =>{
          label: "30 Days",
          type: "pct 0",
          hint: "",
          indent: 2,
        },
        "percent_joined_60_days" =>{
          label: "60 Days",
          type: "pct 0",
          hint: "",
          indent: 2,
        },
        "percent_joined_120_days" =>{
          label: "120 Days",
          type: "pct 0",
          hint: "",
          indent: 2,
        },
        "percent_retained_post_activation_30_days" =>{
          label: "30 Day Retention",
          type: "pct 0",
          hint: "Percent user who had unique activity session within 30 days of activation",
          css: "kpi-tooltip",
          indent: 1,
        },
        "percent_retained_post_activation_60_days" =>{
          label: "60 Day Retention",
          type: "pct 0",
          hint: "Percent user who had unique activity session within 60 days of activation",
          css: "kpi-tooltip",
          indent: 1,
        },
        "percent_retained_post_activation_120_days" =>{
          label: "120 Day Retention",
          type: "pct 0",
          hint: "Percent user who had unique activity session within 120 days of activation",
          css: "kpi-tooltip",
          indent: 1,
        },
      }
    end

    private
    def curr_nps_data
     @nps_data ||= Integrations::NetPromoterScore.get_metrics({trend: PAID_CLIENTS_DELIGHTED_TREND })
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
      }
    end

    def set_current_percent
      scope = User.select([:id, :accepted_invitation_at]).joins(:demo).where(demo: { is_paid: true } )

      joined_users = scope.where(User.arel_table[:accepted_invitation_at].not_eq(nil))

      percent = (joined_users.count.to_f / scope.count).round(2)

    end
  end
end
