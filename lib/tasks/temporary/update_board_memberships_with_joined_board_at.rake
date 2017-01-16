namespace :admin do
  desc "Update board memberships to have joined board at"
  task update_joined_board_at_on_board_membership: :environment do
    Channel.all.each { |c| c.update_attributes(image_header: c.name)}
  end
end
