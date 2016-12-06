desc "Restores most important images after a pg_restore"
namespace :restore do
  task images: :environment do
    def image_from_url(object, image_attachment_method, url)
      extname = File.extname(url)
      basename = File.basename(url, extname)

      file = Tempfile.new([basename, extname])
      file.binmode

      open(URI.parse(url)) do |data|
        file.write data.read
      end

      file.rewind

      object.send("#{image_attachment_method}=", file)
      object.save
    end

    Tile.copyable.each { |tile|
      image_from_url(tile, "image", "https://unsplash.it/200/?random")
    }
  end
end
