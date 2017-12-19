task remove_link_addresses: :environment do |t|
  Tile.where("link_address != ''").each do |tile|
    puts "Updating Tile #{tile.id}; #{tile.headline}"
    tile.supporting_content << "<p><a href=#{tile.link_address}>#{tile.link_address}</a></p>"

    if tile.save
      tile.update_attributes(link_address: '')
      puts "Update successful."
    end
  end
end
