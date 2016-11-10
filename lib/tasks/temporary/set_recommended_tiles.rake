namespace :db do
  namespace :admin do
    desc "set recommended tiles"
    task set_recommended_tiles: :environment do
      [18894, 18893, 18890, 18858, 18896, 18856].each { |t|
        RecommendedTile.create(tile_id: t)
      }
    end
  end
end

# rake db:admin:set_recommended_tiles
