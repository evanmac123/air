class CampaignTile < ActiveRecord::Base
  belongs_to :tile
  # TODO: Move this touch to the object that manages Tile updates/Campaign subscriptions so that it only touches when the Tile is posted.
  belongs_to :campaign, touch: true
end
