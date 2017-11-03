require 'acceptance/acceptance_helper'

feature "Explore", js: true do
  before do
    @demo = FactoryGirl.create(:demo)
    @user = FactoryGirl.create(:user, is_client_admin: true, demo: @demo)
    @tiles = FactoryGirl.create_list(:tile, 3, is_public: true, demo: @demo)

    @tile_feature_1 = FactoryGirl.create(:tile_feature, name: "tile_feature_1", rank: 1, active: true)
    @tile_feature_2 = FactoryGirl.create(:tile_feature, name: "tile_feature_2", rank: 2, active: false)
    @tile_feature_3 = FactoryGirl.create(:tile_feature, name: "tile_feature_3", rank: 3, active: true)

    TileFeature.scoped.each_with_index do |tf, i|
      tf.dispatch_redis_updates({
        header_copy: tf.name,
        tile_ids: @tiles[i].id.to_s
      })
    end

    FactoryGirl.create_list(:channel, 12, active: true)
    FactoryGirl.create(:channel, active: false)

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
