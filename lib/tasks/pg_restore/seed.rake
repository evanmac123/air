desc "Restores most important images after a pg_restore"
namespace :pg_restore do
  namespace :seed do
    task explore_images: :environment do
      Tile.copyable.each { |tile|
        img_link = "http://localhost:3000/system/tile_image_seed.png"
        tile.remote_media_url = img_link
        tile.save
      }
    end
  end
end
