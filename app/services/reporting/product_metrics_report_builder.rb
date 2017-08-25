class Reporting::ProductMetricsReportBuilder
  def self.build_week(to_date:)
    from_date = to_date.beginning_of_week

    ProductMetricsReport.where({ from_date: from_date, to_date: to_date, period_cd: ProductMetricsReport.periods[:week] }).delete_all

    Reporting::ProductMetricsReportBuilder.new(from_date: from_date, to_date: to_date, period: :week).run
  end

  def self.build_month(to_date:)
    from_date = to_date.beginning_of_month

    ProductMetricsReport.where({ from_date: from_date, to_date: to_date, period_cd: ProductMetricsReport.periods[:month] }).delete_all

    Reporting::ProductMetricsReportBuilder.new(from_date: from_date, to_date: to_date, period: :month).run
  end

  attr_reader :date_range, :report

  def initialize(from_date:, to_date:, period:)
    @report = ProductMetricsReport.new(from_date: from_date, to_date: to_date, period_cd: ProductMetricsReport.periods[period])
    @date_range = @report.date_range
  end

  def run
    report.assign_attributes({
      smb_tiles_delivered: smb_tiles_delivered,
      smb_overall_completion_rate: smb_overall_tile_completion_report[:mean],
      smb_completion_rate_in_range: smb_tile_completion_report_in_range[:mean],
      smb_overall_view_rate: smb_overall_tile_view_report[:mean],
      smb_view_rate_in_range: smb_tile_view_report_in_range[:mean],
      smb_percent_orgs_posted: smb_percent_orgs_posted,
      smb_percent_orgs_activity: smb_percent_orgs_activity,
      smb_percent_orgs_copied: smb_percent_orgs_copied,
      enterprise_tiles_delivered: enterprise_tiles_delivered,
      enterprise_overall_completion_rate: enterprise_overall_tile_completion_report[:mean],
      enterprise_completion_rate_in_range: enterprise_tile_completion_report_in_range[:mean],
      enterprise_overall_view_rate: enterprise_overall_tile_view_report[:mean],
      enterprise_view_rate_in_range: enterprise_tile_view_report_in_range[:mean],
      enterprise_percent_orgs_posted: enterprise_percent_orgs_posted,
      enterprise_percent_orgs_activity: enterprise_percent_orgs_activity,
      enterprise_percent_orgs_copied: enterprise_percent_orgs_copied
    })

    report
  end

  def smb_tiles_delivered
    @_smb_tiles_delivered ||= tiles_digests_in_range_scope(scope: smb_tiles_digests).joins(:tiles_digest_tiles).count
  end

  def smb_overall_tile_completion_report
    @_smb_overall_tile_completion_report ||= smb_tiles_digests.tile_completion_report.stats_base
  end

  def smb_tile_completion_report_in_range
    @_smb_tile_completion_report_in_range ||= tiles_digests_in_range_scope(scope: smb_tiles_digests).tile_completion_report.stats_base
  end

  def smb_overall_tile_view_report
    @_smb_overall_tile_view_report ||= smb_tiles_digests.tile_view_report.stats_base
  end

  def smb_tile_view_report_in_range
    @_smb_tile_view_report_in_range ||= tiles_digests_in_range_scope(scope: smb_tiles_digests).tile_view_report.stats_base
  end

  def smb_percent_orgs_posted
    @_smb_percent_orgs_posted ||= smb_organizations.joins(:tiles).where(tiles: { activated_at: date_range }).uniq.count / smb_organizations.count.to_f
  end

  def smb_percent_orgs_copied
    @_smb_percent_orgs_copied ||= smb_organizations.joins(:tiles).where(tiles: { creation_source_cd: Tile.creation_sources[:explore_created] }).where(tiles: { created_at: date_range }).uniq.count / smb_organizations.count.to_f
  end

  def smb_percent_orgs_activity
    smb_org_ids = smb_organizations.pluck(:id)
    non_active_smb = smb_org_ids - paid_org_ids_with_activity

    (smb_org_ids.length - non_active_smb.length)/smb_org_ids.length.to_f
  end

  def enterprise_tiles_delivered
    @_enterprise_tiles_delivered ||= tiles_digests_in_range_scope(scope: enterprise_tiles_digests).joins(:tiles_digest_tiles).count
  end

  def enterprise_overall_tile_completion_report
    @_enterprise_overall_tile_completion_report ||= enterprise_tiles_digests.tile_completion_report.stats_base
  end

  def enterprise_tile_completion_report_in_range
    @_enterprise_tile_completion_report_in_range ||= tiles_digests_in_range_scope(scope: enterprise_tiles_digests).tile_completion_report.stats_base
  end

  def enterprise_overall_tile_view_report
    @_enterprise_overall_tile_view_report ||= enterprise_tiles_digests.tile_view_report.stats_base
  end

  def enterprise_tile_view_report_in_range
    @_enterprise_tile_view_report_in_range ||= tiles_digests_in_range_scope(scope: enterprise_tiles_digests).tile_view_report.stats_base
  end

  def enterprise_percent_orgs_posted
    @_enterprise_percent_orgs_posted ||= enterprise_organizations.joins(:tiles).where(tiles: { activated_at: date_range }).uniq.count / enterprise_organizations.count.to_f
  end

  def enterprise_percent_orgs_copied
    @_enterprise_percent_orgs_copied ||= enterprise_organizations.joins(:tiles).where(tiles: { creation_source_cd: Tile.creation_sources[:explore_created] }).where(tiles: { created_at: date_range }).uniq.count / enterprise_organizations.count.to_f
  end

  def enterprise_percent_orgs_activity
    enterprise_org_ids = enterprise_organizations.pluck(:id)
    non_active_enterprise = enterprise_org_ids - paid_org_ids_with_activity

    (enterprise_org_ids.length - non_active_enterprise.length)/enterprise_org_ids.length.to_f
  end

  # private

    def paid_org_ids_with_activity
      @_org_ids_with_activity ||= $mixpanel_client.request("jql", { script: activity_session_jql_script }).map { |data| data["key"] }.flatten
    end

    def activity_session_jql_script
      %Q| function main() {
        return Events(
          {
            from_date: "#{report.mp_from_date}",
            to_date: "#{report.mp_to_date}",
            event_selectors: [
              {
                event: 'Activity Session - New',
                selector: 'properties["user_type"] == "client admin" and  properties["board_type"] == "Paid"'
              },
            ]
          })
          .groupBy(["properties.organization"], mixpanel.reducer.null());
        }
      |
    end

    def mixpanel_opts
      { from_date: report.from_date, to_date: report.to_date, unit: report.period.to_s }
    end

    def smb_organizations
      Organization.paid_at_date(date: report.to_date).smb
    end

    def enterprise_organizations
      Organization.paid_at_date(date: report.to_date).enterprise
    end

    def smb_tiles_digests
      TilesDigest.paid.smb
    end

    def enterprise_tiles_digests
      TilesDigest.paid.enterprise
    end

    def tiles_digests_in_range_scope(scope:)
      scope.where(sent_at: date_range)
    end
end
