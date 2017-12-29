class BaseTilesDigestMailer < ApplicationMailer
  helper :email
  helper 'client_admin/tiles'
  helper ApplicationHelper

  include EmailHelper
  include ClientAdmin::TilesHelper

  layout nil

  default reply_to: 'support@airbo.com'

  def self.digest_types_for_mixpanel
    {
      "tile_digest" => "Digest - v. 6/15/14",
      "follow_up_digest" => "Follow-up - v. 6/15/14",
      "explore_digest"  => "Explore - v. 1/1/17",
      "weekly_activity_report"  => "Weekly Report - v. 5/20/15",
    }
  end

  private

    def tiles_by_position
      Tile.where(id: @tile_ids).ordered_by_position
    end
end
