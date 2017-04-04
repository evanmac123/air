namespace :admin do
  desc "Update historical tile_creation source"
  task update_tile_creation_source: :environment do
    puts "Updating tiles created from explore"
    Tile.where("original_creator_id IS NOT NULL").update_all(creation_source_cd: 1)
  end
end

# rake admin:update_tile_creation_source
