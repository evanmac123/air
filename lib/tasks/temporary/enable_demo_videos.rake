namespace :db do
  namespace :admin do
    desc "Update demos to enable videos"
    task enable_demo_videos: :environment do
      puts "Going to update #{Demo.where(allow_embed_video: false).count} demos to enable videos."

      Demo.where(allow_embed_video: false).update_all(allow_embed_video: true)

      puts "All done. Demo count: #{Demo.count}. Demo count with videos enabled: #{Demo.where(allow_embed_video: true).count}."
    end
  end
end
