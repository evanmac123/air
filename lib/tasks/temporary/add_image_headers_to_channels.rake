namespace :admin do
  desc "Update image headers on channels"
  task add_channel_image_headers: :environment do
    Channel.all.each { |c| c.update_attributes(image_header: c.name)}
  end
end
