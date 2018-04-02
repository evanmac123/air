task update_campaign_tiles: :environment do
  CampaignTile.all.each do |ct|
    puts "Updating Tile #{ct.tile_id}."
    t = ct.tile
    t.campaign_id = ct.campaign_id
    t.save
  end
end
