desc "Restores most important images after a pg_restore"
namespace :env_sync do
  task core_images: :environment do
    images = JSON.parse(Net::HTTP.get('unsplash.it', '/list'))
    image_ids = images.map { |img| img["id"] }

    tile_images = TileImage.all_ready.limit(50)

    tile_images.each_with_index { |tile_image, i|
      puts "Getting image #{i + 1} from Unsplash..."
      img_link = URI.parse(URI.encode("https://unsplash.it/200?image=#{image_ids.sample}"))
      tile_image.image = img_link
      tile_image.thumbnail = img_link
      tile_image.save
    }

    puts "Retrieving Tile ids to populate..."
    tile_image_ids = tile_images.pluck(:id)
    tiles_to_update = []

    Demo.airbo.each { |demo|
      demo.tiles.each { |tile|
        tiles_to_update << tile.id
      }
    }

    #adds images to Take5
    Demo.find_by_id(222).tiles.each { |tile|
      tiles_to_update << tile.id
    }

    #adds images to weilandia
    Demo.find_by_id(1630).tiles.each { |tile|
      tiles_to_update << tile.id
    }

    Tile.explore.each { |tile|
      tiles_to_update << tile.id
    }

    puts "Updating #{tiles_to_update.uniq.count} Tiles..."

    tiles_to_update.uniq.each { |tile_id|
      puts "Adding image for Tile #{tile_id}"
      ImageProcessJob.new(tile_id, tile_image_ids.sample).perform
    }

    Channel.all.each { |channel|
      puts "Adding image for Channel #{channel.id}"
      channel.image = URI.parse(URI.encode("https://unsplash.it/200/400/?random"))
      channel.save
    }

    Campaign.all.each { |campaign|
      puts "Adding image for Campaign #{campaign.id}"

      campaign.cover_image = URI.parse(URI.encode("https://unsplash.it/300/400/?random&blur"))

      campaign.save
    }
  end
end
