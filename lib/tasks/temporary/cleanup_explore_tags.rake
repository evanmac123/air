namespace :admin do
  desc "Cleanup explore tags"
  task cleanup_explore_tags: :environment do
    puts "Building Org slugs"
    Organization.all.each { |c| c.save }
    puts "Org slugs updated"

    puts "Removing old org tags"
    Tile.explore.reverse.each { |t|
      org = t.organization.name
      t.channel_list.remove(org)
      t.save
    }


    puts "Updating internal orgs"
    internal = Organization.find_by_slug("airbo")
    if internal
      internal.update_attributes(internal: true)
    end

    puts "Updating org created at dates"
    Organization.all.each do |org|
      first_board = org.boards.order(:created_at).first
      if first_board
        org.update_attributes(created_at: first_board.created_at)
      end
    end
  end
end
