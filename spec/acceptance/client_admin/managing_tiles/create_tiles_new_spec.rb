# require 'acceptance/acceptance_helper'
# feature "Client admin creates tiles", js: true do
#
#   context "new tile" do
#     let (:client_admin) { FactoryBot.create(:client_admin)}
#     let (:demo)         { client_admin.demo }
#
#     before(:each) do
#       visit client_admin_tiles_path(as: client_admin)
#     end
#
#     scenario "Creates new tile" do
#       click_add_new_tile
#       fill_in_tile_form_entries(edit_text: "baz", points: "10")
#       click_tile_create_button
#       page.find(".viewer")
#
#       within ".viewer" do
#         expect(page).to  have_content "by Society"
#         expect(page).to  have_content "Ten pounds of cheese"
#         expect(page).to  have_content "Ten pounds of cheese. Yes? Or no?"
#         expect(page).to  have_content "Who rules?"
#       end
#
#       expect(page).to have_selector("a.multiple-choice-answer.correct ", text: "Youbaz")
#       expect(page).to have_selector("#tile_point_value", text: "10")
#     end
#   end
#
#   context "existing tile" do
#     let(:edit_text){"baz"}
#     let(:points){"10"}
#
#     before(:each) do
#       tile = FactoryBot.create :multiple_choice_tile, question_type: "survey", question_subtype: "multiple_choice"
#       client_admin = FactoryBot.create(:client_admin, demo: tile.demo)
#       visit client_admin_tiles_path(as: client_admin)
#
#       active_tab.click
#
#       within "#single-tile-#{tile.id}" do
#         page.find(".tile-wrapper").hover
#         page.find("li.edit_button a").click
#       end
#     end
#
#     scenario "check tile content in form fields" do
#       within ".new_tile_builder_form" do
#         expect(page).to  have_content "This is some extra text by the tile"
#         expect(page).to  have_field "tile_question", with: "Which of the following comes out of a bird?"
#         expect(page).to  have_content "Ham"
#         expect(page).to  have_content "Eggs"
#         expect(page).to  have_content "A V8 Buick"
#       end
#     end
#   end
# end
