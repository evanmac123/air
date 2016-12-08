desc "Restores most important images after a pg_restore"
namespace :pg_restore do
  namespace :seed do
    task tile_images: :environment do
      images = JSON.parse(Net::HTTP.get('unsplash.it', '/list'))
      image_ids = images.map { |img| img["id"] }

      tile_images = TileImage.all_ready.limit(200)

      tile_images.each { |tile_image|
        img_link = URI.parse(URI.encode("https://unsplash.it/200?image=#{image_ids.sample}"))
        tile_image.image = img_link
        tile_image.thumbnail = img_link
        tile_image.save
      }

      tile_image_ids = tile_images.pluck(:id)

      Tile.copyable.each { |tile|
        ImageProcessJob.new(tile.id, tile_image_ids.sample).perform
      }
    end
  end
end
