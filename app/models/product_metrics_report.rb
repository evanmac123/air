class ProductMetricsReport < ActiveRecord::Base
  as_enum :period, week: 0, month: 1

  def build
    self.assign_attributes({
      smb_tiles_delivered: tiles_delivered(scope: smb_tiles_digests_in_range),
      smb_overall_completion_rate: tile_completion_report(scope: smb_tiles_digests)[:mean],
      smb_completion_rate_in_range: tile_completion_report(scope: smb_tiles_digests_in_range)[:mean],
      smb_overall_view_rate: tile_view_report(scope: smb_tiles_digests)[:mean],
      smb_view_rate_in_range: tile_view_report(scope: smb_tiles_digests_in_range)[:mean],
      smb_percent_orgs_posted: percent_orgs_posted(scope: smb_organizations),
      smb_percent_orgs_activity: percent_orgs_activity(scope: smb_organizations),
      smb_percent_orgs_copied: percent_orgs_copied(scope: smb_organizations),
      smb_digest_active_user_rate_in_range: digest_active_user_rate(scope: smb_tiles_digests_in_range)[:mean],
      smb_mau_rate: mau_rate(scope: smb_tiles_digests_in_range),
      enterprise_tiles_delivered: tiles_delivered(scope: enterprise_tiles_digests_in_range),
      enterprise_overall_completion_rate: tile_completion_report(scope: enterprise_tiles_digests)[:mean],
      enterprise_completion_rate_in_range: tile_completion_report(scope: enterprise_tiles_digests_in_range)[:mean],
      enterprise_overall_view_rate: tile_view_report(scope: enterprise_tiles_digests)[:mean],
      enterprise_view_rate_in_range: tile_view_report(scope: enterprise_tiles_digests_in_range)[:mean],
      enterprise_percent_orgs_posted: percent_orgs_posted(scope: enterprise_organizations),
      enterprise_percent_orgs_activity: percent_orgs_activity(scope: enterprise_organizations),
      enterprise_percent_orgs_copied: percent_orgs_copied(scope: enterprise_organizations),
      enterprise_digest_active_user_rate_in_range: digest_active_user_rate(scope: enterprise_tiles_digests_in_range)[:mean],
      enterprise_mau_rate: mau_rate(scope: enterprise_tiles_digests_in_range)
    })

    self
  end

  def tiles_delivered(scope:)
    scope.joins(:tiles_digest_tiles).count
  end

  def tile_completion_report(scope:)
    scope.tile_completion_report.stats_base
  end

  def tile_view_report(scope:)
    scope.tile_view_report.stats_base
  end

  def percent_orgs_posted(scope:)
    scope.joins(:tiles).where(tiles: { activated_at: date_range }).uniq.count / scope.count.to_f
  end

  def percent_orgs_activity(scope:)
    active_org_ids = scope.pluck(:id)
    non_active_org_ids = active_org_ids - paid_org_ids_with_activity

    (active_org_ids.length - non_active_org_ids.length)/active_org_ids.length.to_f
  end

  def percent_orgs_copied(scope:)
    scope.joins(:tiles).where(tiles: { creation_source_cd: Tile.creation_sources[:explore_created] }).where(tiles: { created_at: date_range }).uniq.count / scope.count.to_f
  end

  def digest_active_user_rate(scope:)
    scope.active_user_report.stats_base
  end

  def mau_rate(scope:)
    eligible_uids = scope.map { |d|
      d.users.pluck(:id)
    }.flatten.uniq

    if eligible_uids.count > 0
      uniq_uids_satisfying_mau_key_metric(recipient_ids: eligible_uids).count/eligible_uids.count.to_f
    end
  end

  private

    def date_range
      from_date..to_date
    end

    def mp_from_date
      from_date.strftime("%Y-%m-%d")
    end

    def mp_to_date
      to_date.strftime("%Y-%m-%d")
    end

    def uniq_uids_satisfying_mau_key_metric(recipient_ids:)
      tile_ids = Tile.where(activated_at: date_range).pluck(:id)
      TileCompletion.where(created_at: from_date..(to_date + 10.days)).where(user_id: recipient_ids).where(tile_id: tile_ids).pluck(:user_id).uniq
    end

    def tiles_digests_in_range_scope(scope:)
      scope.where(sent_at: date_range)
    end

    def tiles_digests
      TilesDigest.paid
    end

    def smb_tiles_digests
      tiles_digests.smb
    end

    def enterprise_tiles_digests
      tiles_digests.enterprise
    end

    def smb_tiles_digests_in_range
      tiles_digests_in_range_scope(scope: smb_tiles_digests)
    end

    def enterprise_tiles_digests_in_range
      tiles_digests_in_range_scope(scope: enterprise_tiles_digests)
    end

    def organizations
      Organization.paid_at_date(date: to_date)
    end

    def smb_organizations
      organizations.smb
    end

    def smb_organizations_count
      smb_organizations.count.to_f
    end

    def enterprise_organizations_count
      enterprise_organizations.count.to_f
    end

    def enterprise_organizations
      organizations.enterprise
    end


    def paid_org_ids_with_activity
      @_org_ids_with_activity ||= $mixpanel_client.request("jql", { script: activity_session_jql_script }).map { |data| data["key"] }.flatten
    end

    def activity_session_jql_script
      %Q| function main() {
        return Events(
          {
            from_date: "#{mp_from_date}",
            to_date: "#{mp_to_date}",
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
end
