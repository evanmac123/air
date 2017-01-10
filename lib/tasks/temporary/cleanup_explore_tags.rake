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
  end
end
