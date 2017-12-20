desc "Restores most important images after a pg_restore"
namespace :env_sync do
  task core_images: :environment do
    url = "https://api.unsplash.com/photos/curated?per_page=50&client_id=7623e7127635c01fb16aae701780e7d8d8edadf45234cd8cf8f063a299d896b9"
    images = JSON.parse(Net::HTTP.get(URI.parse(url)))
    image_urls = images.map { |img| URI.parse(URI.encode(img["urls"]["small"])) }

    puts "Retrieving Tile ids to populate..."
    tiles_to_update = []

    Demo.airbo.each { |demo|
      demo.tiles.each { |tile|
        tiles_to_update << tile
      }
    }
    #adds images to Take5
    Demo.find_by(id: 222).tiles.each { |tile|
      tiles_to_update << tile
    }

    Tile.explore.each { |tile|
      tiles_to_update << tile
    }

    Organization.find_by(id: 37).demos.each { |demo|
      demo.tiles.each { |tile|
        tiles_to_update << tile
      }
    }

    puts "Updating #{tiles_to_update.uniq.count} Tiles..."

    tiles_to_update.uniq.each { |tile|
      puts "Adding image for Tile #{tile}"
      tile.image = tile.thumbnail = image_urls.sample
      tile.save
    }

    Channel.all.each { |channel|
      puts "Adding image for Channel #{channel.id}"
      channel.image = image_urls.sample
      channel.save
    }

    Campaign.all.each { |campaign|
      puts "Adding image for Campaign #{campaign.id}"
      campaign.cover_image = image_urls.sample
      campaign.save
    }

    Demo.where("logo_file_name IS NOT NULL").each { |d|
      d.logo = nil
      d.save
    }

    User.where("avatar_file_name IS NOT NULL").each { |d|
      d.avatar = nil
      d.save
    }
  end
end
