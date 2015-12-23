namespace :db do
  namespace :library_images do
    desc "Reprocesses all tile images in the system"
    task :reprocess => :environment do
      TileImage.all.each do |ti|
        ti.image.reprocess!
      end
    end
  end
end
