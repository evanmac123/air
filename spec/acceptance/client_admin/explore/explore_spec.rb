require 'acceptance/acceptance_helper'

feature "Explore" do
  before(:each) do
    @demo = FactoryGirl.create(:demo)
    @user = FactoryGirl.create(:user, is_client_admin: true, demo: @demo)
    @tiles = FactoryGirl.create_list(:tile, 3, is_public: true, demo: @demo)
  end

  context "when user visits explore" do
    context "channels" do
      before(:each) do
        @channel_1 = FactoryGirl.create(:tile_feature, name: "channel_1", rank: 1, active: true)
        @channel_2 = FactoryGirl.create(:tile_feature, name: "channel_2", rank: 2, active: false)
        @channel_3 = FactoryGirl.create(:tile_feature, name: "channel_3", rank: 3, active: true)

        TileFeature.scoped.each { |tf| tf.dispatch_redis_updates({ header_copy: tf.name, tile_ids: Tile.find(tf.rank).id.to_s }) }
      end

      scenario "should only display active channels with tiles" do
        visit explore_path(as: @user)

        within "section#channel_1" do
          expect(page).to have_css('.explore-headers', text: "channel_1")
          expect(page).to have_content(Tile.find(1).headline)
        end

        expect(page).to_not have_css('#channel_2')

        within "section#channel_3" do
          expect(page).to have_css('.explore-headers', text: "channel_3")
          expect(page).to have_content(Tile.find(3).headline)
        end
      end
    end
  end
end
