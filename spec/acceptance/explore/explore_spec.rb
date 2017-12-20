require 'acceptance/acceptance_helper'

feature "Explore", js: true do
  before do
    @demo = FactoryBot.create(:demo)
    @user = FactoryBot.create(:user, is_client_admin: true, demo: @demo)
    @tiles = FactoryBot.create_list(:tile, 3, is_public: true, demo: @demo)

    @tile_feature_1 = FactoryBot.create(:tile_feature, name: "tile_feature_1", rank: 1, active: true)
    @tile_feature_2 = FactoryBot.create(:tile_feature, name: "tile_feature_2", rank: 2, active: false)
    @tile_feature_3 = FactoryBot.create(:tile_feature, name: "tile_feature_3", rank: 3, active: true)

    TileFeature.all.each_with_index do |tf, i|
      tf.dispatch_redis_updates({
        header_copy: tf.name,
        tile_ids: @tiles[i].id.to_s
      })
    end

    FactoryBot.create_list(:channel, 12, active: true)
    FactoryBot.create(:channel, active: false)

    visit explore_path(as: @user)
  end

  context "when user visits explore" do
    context "tile_features" do
      scenario "should only display active tile_features with tiles" do
        within "section#tile_feature_1" do
          expect(page).to have_css('.explore-headers', text: "tile_feature_1")
          expect(page).to have_content(Tile.first.headline)
        end

        expect(page).to_not have_css('#tile_feature_2')

        within "section#tile_feature_3" do
          expect(page).to have_css('.explore-headers', text: "tile_feature_3")
          expect(page).to have_content(Tile.last.headline)
        end
      end
    end

    context "channels" do
      scenario "channels should appear in top bar and provide nav to channels and back to explore" do
        within "section#channels" do
          expect(page).to have_selector(".channel_overlay", 12)
        end
      end
    end
  end
end
