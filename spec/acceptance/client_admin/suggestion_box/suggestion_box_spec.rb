# require 'acceptance/acceptance_helper'
#
# feature 'Client uses suggestion box' do
#   include SuggestionBox
#
#   let!(:demo) { FactoryBot.create :demo }
#   let!(:client_admin) { FactoryBot.create :site_admin, demo: demo }
#
#   context "Submitted Tile", js: true do
#
#     let!(:tile) { FactoryBot.create :multiple_choice_tile, :user_submitted, demo: demo }
#
#     before do
#       visit client_admin_tiles_path(as: client_admin)
#       suggested_tab.click
#     end
#
#     scenario "tile preview works properly" do
#       page.find("#single-tile-#{tile.id}.user_submitted").click
#
#       within "#suggested_info" do
#         expect(page.find(".header_text").text).to have_content("Submitted")
#       end
#
#       items = menu_items.map(&:text)
#       expect(items).to include("Accept")
#       expect(items).to include("Ignore")
#     end
#
#     scenario "accepts tile" do
#       within ".tile_container .user_submitted" do
#         page.find(".tile-wrapper").hover
#       end
#
#       click_link "Accept"
#
#       plan_tab.click
#
#       within ".js-plan-tiles-component" do
#         expect(page).to have_css("#single-tile-#{tile.id}")
#       end
#     end
#
#     context "Ignored Tile" do
#
#       before  do
#         within ".tile_container .user_submitted" do
#           page.find(".tile-wrapper").hover
#         end
#         within "#single-tile-#{tile.id}" do
#           click_link "Ignore"
#         end
#       end
#
#       scenario "should ignore tile" do
#         within "#single-tile-#{tile.id}" do
#           expect(page).to have_content("Undo Ignore")
#         end
#       end
#
#       scenario "should undo ignore" do
#         within "#single-tile-#{tile.id}" do
#           click_link("Undo Ignore")
#         end
#
#         within "#single-tile-#{tile.id}" do
#           expect(page).not_to have_content("Undo Ignore")
#         end
#       end
#     end
#   end
#
#   def menu_items
#     page.all(".preview_menu_item .header_text")
#   end
# end
