task reprocess_images: :environment do
  puts "Reprocessing User Avatars"
  User.where("avatar_file_name IS NOT NULL").each { |u|
    puts "Processing User: #{u.id}..."
    u.avatar.reprocess!
  }

  puts "Reprocessing TileImages (former image library)"
  TileImage.find_each { |t|
    puts "Processing TileImage: #{t.id}"
    t.image.reprocess!
    t.thumbnail.reprocess!
  }

  puts "Reprocessing Tiles"
  Tile.find_each { |t|
    puts "Processing Tile: #{t.id}"
    t.image.reprocess!
    t.thumbnail.reprocess!
  }

  puts "Reprocessing Board cover images"
  Demo.where("cover_image_file_name IS NOT NULL").each { |d|
    d.cover_image.reprocess!
  }

  puts "Reprocessing Board logos"
  Demo.where("logo_file_name IS NOT NULL").each { |d|
    d.logo.reprocess!
  }


  puts "Reprocessing is complete. You now need to wait until all background jobs are complete. The current number of background jobs is #{Delayed::Job.count}"
end
