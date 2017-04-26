module Reporting
  class ClientKPIReport <KpiReportingBase

    WEEKLY="weekly"
    MONTHLY="monthly"

    #FIXME move this constant to common location to remove duplication
    PAID_CLIENTS_DELIGHTED_TREND = 75029

    def default_date_range
      edate = Date.today.beginning_of_week
      sdate = edate.advance(weeks: -5)
      [sdate, edate]
    end

    def current_by_period(period=WEEKLY)
      @curr ||= CustSuccessKpi.by_period(period).last
    end

    def chart_series_names
      chart_series_names
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
          "percent_orgs_that_copied_tiles",
          "average_tiles_copied_per_org_that_copied",

          "tiles_created_from_scratch",
          "orgs_that_created_tiles_from_scratch",
          "average_tiles_created_from_scratch_per_org_that_created",
          "percent_of_orgs_that_posted_tiles"
        ],

      }
    end

    def chart_series_names
      kpi_fields.inject({}){|h, (k,v)| h[v[:series]]=k if v[:series]; h}
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
          series: "Net Promoter Score (NPS)",
          type: "num",
          hint: "Rolling 90 days",
          indent: 0,
          css: " kpi-tooltip"
        },
        "paid_net_promoter_score_response_count" => {
          label: "Responses",
          series: "NPS Responses",
          type: "num",
          hint: "",
          indent: 1,
        },
        "percent_engaged_organizations" =>{
          label: "Customer Engagement",
          series: "% Customer Engagement",
          type: "pct 0",
          hint: "",
          indent: 0,
          css: ""
        },
        "unique_org_with_activity_sessions" =>{
          label: "Engaged ",
          series: "Unique Customers Activity Sessions ",
          type: "num",
          hint: "Unique Organizations with One or More Activity Session",
          css: "kpi-tooltip",
          indent: 1,
        },
        "total_paid_orgs" =>{
          label: "Customers",
          series: "Total Paid Customers",
          type: "num",
          hint: "",
          indent: 1,
        },
        "percent_engaged_client_admin" =>{
          label: "Client Admin Engagement",
          series: "% Client Admin Engagement",
          type: "pct 0",
          hint: "",
          indent: 0,
          css: ""
        },
        "unique_client_admin_with_activity_sessions" =>{
          label: "Engaged",
          series: "Client Admins W/ Activity Sessions",
          type: "num",
          hint: "Unique Paid Client Admins with One or More Activity Session",
          css: "kpi-tooltip",
          indent: 1,
        },
        "total_paid_client_admins" =>{
          label: "Client Admins" ,
          label: "Paid Client Admins" ,
          type: "num",
          hint: "",
          indent: 1,
        },

        "total_paid_client_admin_activity_sessions" =>{
          label: "Total Activity Sessions",
          series: "Total Paid Client Admin Activity Sessions",
          type: "num",
          hint: "",
          indent: 0,
        },
        "activity_sessions_per_client_admin" =>{
          label: "Per Engaged Client Admin",
          series: "Activity Sessions Per Engaged",
          type: "num",
          hint: "Activity Sessions Per Engaged Client Admin",
          css: "kpi-tooltip",
          indent: 1,
        },


        "percent_paid_orgs_view_tile_in_explore" => {
          label: "Explore Engagement",
          series: "% Customers Viewed Tile in Explore",
          type: "pct 0",
          hint: "% of Paid Organizations that viewed a Tile in Airbo Explore",
          indent: 0,
          css: " kpi-tooltip"
        },
        "total_tiles_viewed_in_explore_by_paid_orgs" => {
          label: "Total Tile Views",
          series: "Explore Customer Tile Views",
          type: "num",
          hint: "Total # of Tiles viewed in Explore by Paid Organizations",
          css: "kpi-tooltip",
          indent: 0
        },
        "paid_client_admins_who_viewed_tiles_in_explore" => {
          label: "Unique Tile Views",
          series: "Client Admin Tile Views",
          type: "num",
          hint: "# of client admins that viewed Tiles",
          css: "kpi-tooltip",
          indent: 1
        },
        "tiles_viewed_per_paid_client_admin" => {
          label: "Avg Tile Views",
          series: "Avg. Client Admin Tile Views",
          type: "num",
          hint: "# of Tile Views per Paid Client Admin",
          css: "kpi-tooltip",
          indent: 1
        },
        "percent_orgs_that_added_tiles" => {
          label: "Tile Creation Engagement",
          series: "% Customers Added Tile",
          type: "pct 0",
          hint: "% of Paid Organizations that added a tile",
          indent: 0,
          css: " kpi-tooltip"
        },
        "total_tiles_added_by_paid_client_admin" => {
          label: "Total Tiles Added",
          series: "Total Tiles Added",
          type: "num",
          hint: "# Total Tiles Copied or Created by Paid Client Admins",
          css: "kpi-tooltip",
          indent: 0
        },
        "unique_orgs_that_added_tiles" => {
          label: "Customers",
          series: "# Customers That Added Tiles",
          type: "num",
          hint: "# of customers that copied or created Tiles",
          css: "kpi-tooltip",
          indent: 1
        },
        "percent_of_added_tiles_from_copy" => {
          label: "Copied",
          series: "% Tiles Added from Copy",
          type: "pct 0",
          hint: "% of New Tiles that were copied from Explore",
          css: "kpi-tooltip",
          indent: 1
        },
        "percent_of_added_tiles_from_scratch" => {
          label: "Created",
          series: "% Tiles Added From Scratch",
          type: "pct 0",
          hint: "% of New Tiles that were created from scratch",
          css: "kpi-tooltip",
          indent: 1
        },
        "percent_orgs_that_copied_tiles" =>{
          label: "Copied",
          series: "% Customers That Copied Tiles",
          type: "pct 0",
          hint: "% Customers That Copied Tiles",
          css: "kpi-tooltip",
          indent: 1,
        },
        "total_tiles_added_from_copy_by_paid_client_admin" =>{
          label: "Tiles Copied",
          series: "Total Tiles Copied",
          type: "num",
          hint: "",
          indent: 0,
        },
        "unique_orgs_that_copied_tiles" =>{
          label: "Customers",
          series: "# Customers Copied Tiles",
          type: "num",
          hint: "",
          indent: 1,
        },
        "average_tiles_copied_per_org_that_copied" =>{
          label: "Average",
          series: "Avg # Copied Tiles per Customer",
          type: "num",
          css: "kpi-tooltip",
          hint: "Avg Tiles Copied Per Org that Copied",
          indent: 1,
        },

        "unique_orgs_that_viewed_tiles_in_explore" =>{
          label: "Customers",
          series: "Unique Customers Viewed Tiles in Explore",
          type: "num",
          css: "kpi-tooltip",
          hint: "Unique organizations engaged in Explore",
          indent: 0,
        },
        "orgs_that_posted_tiles" =>{
          label: "Orgs That Posted Tiles",
          series: "# Customers That Posted Tiles",
          type: "num",
          hint: "",
          indent: 0,
        },
        "percent_of_orgs_that_posted_tiles" =>{
          label: "% of Orgs That Posted Tiles",
          series: "% Customers That Posted Tiles",
          type: "pct 0",
          hint: "",
          indent: 0,
        },
        "total_tiles_posted" =>{
          label: "Total Tiles Posted",
          series: "Total Tiles Posted",
          type: "num",
          hint: "",
          indent: 0,
        },
        "average_tiles_posted_per_organization_that_posted" =>{
          label: "Average Tiles Posted Per Organization That Posted Tiles",
          series: "Avg # Tiles Posted per Customer",
          type: "num",
          hint: "",
          indent: 0,
        },

        "tiles_created_from_scratch" => {
          label: "Tiles Created",
          series: "# Tiles Created From Scratch ",
          type: "num",
          hint: "",
          indent: 0
        },
        "orgs_that_created_tiles_from_scratch" => {
          label: "Customers",
          series: "# Customers That Created Tiles From Scratch ",
          type: "num",
          hint: "",
          indent: 1
        },
        "average_tiles_created_from_scratch_per_org_that_created" => {
          label: "Average",
          series: "Avg # Tiles From Scratch per Customer ",
          type: "num",
          hint: "",
          indent: 1
        },

      }
    end

    def db_fields
      CustSuccessKpi.select(query_select_fields)
    end

    private
  end
end
