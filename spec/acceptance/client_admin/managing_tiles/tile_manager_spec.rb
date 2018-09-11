# require 'acceptance/acceptance_helper'
#
# feature 'Client admin and tile manager page', js: true do
#   include TileManagerHelpers
#
#   let(:admin) { FactoryBot.create :client_admin }
#   let(:demo)  { admin.demo  }
#
#   before do
#     visit client_admin_tiles_path(as: admin)
#   end
#
#   context 'Tiles exist for each of the types' do
#     let(:first)   { create_tile headline: 'first headline'  }
#     let(:second)  { create_tile headline: 'second headline' }
#     let(:third)   { create_tile headline: 'third headline' }
#
#     let!(:tiles) { [first, second, third] }
#
#     scenario "The tile content is correct for Active tiles" do
#       tiles.each { |tile| tile.update_attributes status: Tile::ACTIVE }
#
#       visit(client_admin_tiles_path)
#
#       active_tab.click
#
#       expect(page).to have_num_tiles(3)
#
#       tiles.each do |tile|
#         within ".tile_thumbnail[data-tile-id='#{tile.id}']" do
#           expect_content tile.headline
#           expect(page).to have_css "a[data-status='archive']", visible: false
#           expect(page).to have_css "li.edit_button a", visible: false
#         end
#       end
#     end
#
#     scenario "The tile content is correct for Archive tiles" do
#       tiles.each { |tile| tile.update_attributes status: Tile::ARCHIVE }
#
#       visit(client_admin_tiles_path)
#
#       expect(page).to have_num_tiles(0)
#
#       archive_tab.click
#
#       expect(page).to have_num_tiles(3)
#
#       tiles.each do |tile|
#         within ".tile_thumbnail[data-tile-id='#{tile.id}']" do
#           expect_content tile.headline
#           expect(page).to have_css "a[data-status='active']", visible: false
#           expect(page).to have_css "li.edit_button a", visible: false
#         end
#       end
#     end
#
#     context 'Archiving and activating tiles' do
#       scenario "The 'Archive this tile' links work, including setting the 'archived_at' time and positioning most-recently-archived tiles first" do
#         tiles.each { |tile| tile.update_attributes status: Tile::ACTIVE }
#         visit(client_admin_tiles_path)
#
#         active_tab.click
#
#         page.find(".tile_thumbnail[data-tile-id='#{first.id}']").hover
#         page.find(".update_status", text: "Archive", visible: true).click
#
#         expect(page).not_to contain(first.headline)
#
#         archive_tab.click
#
#         expect(page).to contain(first.headline)
#
#         expect(page).to have_num_tiles(1)
#
#         active_tab.click
#         expect(page).to  have_num_tiles(2)
#
#         page.find(".tile_thumbnail[data-tile-id='#{second.id}']").hover
#         page.find(".update_status", text: "Archive", visible: true).click
#
#         archive_tab.click
#         expect(page).to contain(second.headline)
#
#         expect(page).to have_num_tiles(2)
#         expect(page).to have_first_tile(second, Tile::ARCHIVE)
#
#         active_tab.click
#         expect(page).to  have_num_tiles(1)
#       end
#     end
#
#     context 'Tab preservation on tiles index page' do
#       scenario "User should stay on current tab after page is reloaded" do
#         tiles.each { |tile| tile.update_attributes status: Tile::ACTIVE }
#
#         visit(client_admin_tiles_path)
#
#         # user is on live tab and should stay on live tab after creating campaign
#         active_tab.click
#
#         expect(page).to have_num_tiles(3)
#         visit(current_url)
#
#         within "li.js-ca-tiles-index-component-tab.tab.active" do
#           expect_content("Live")
#         end
#       end
#     end
#   end
#
#   it "has a button that you can click on to create a new tile" do
#     visit(client_admin_tiles_path)
#     click_add_new_tile
#   end
# end
