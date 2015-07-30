require 'acceptance/acceptance_helper'

feature 'Client uses suggestion box' do
	include WaitForAjax
	include SuggestionBox

	context "user is not site admin" do

		let!(:admin) { FactoryGirl.create :client_admin, is_site_admin: false }
		let!(:demo)  { admin.demo  }
		let!(:submitted_tiles) { FactoryGirl.create_list :multiple_choice_tile, 3, :user_submitted, demo: demo }

		background do
			bypass_modal_overlays(admin)
			signin_as(admin, admin.password)
		end

		before do
			FactoryGirl.create :multiple_choice_tile, :draft, demo: demo
		end

		scenario "switches between drafts and suggestion box", js: true do
			visit client_admin_tiles_path
			expect_no_content "#suggestion_box_title"
		end
	end


	context "user is site admin" do

		let!(:admin) { FactoryGirl.create :client_admin, is_site_admin: true }
		let!(:demo)  { admin.demo  }
		let!(:submitted_tiles) { FactoryGirl.create_list :multiple_choice_tile, 3, :user_submitted, demo: demo }

		background do
			bypass_modal_overlays(admin)
			signin_as(admin, admin.password)
		end

		before do
			FactoryGirl.create :multiple_choice_tile, :draft, demo: demo
		end

		scenario "switches between drafts and suggestion box", js: true do
			visit client_admin_tiles_path
			# in draft section
			visible_tiles.count.should == 1
			suggestion_box_title.click
			# in suggestion box
			visible_tiles.count.should == 3
			draft_title.click
			# and again in draft section
			visible_tiles.count.should == 1
		end

		context "accepting process" do
			before do
				visit client_admin_tiles_path(show_suggestion_box: true)

				@tile = submitted_tiles[1]
				accept_button(@tile).click
				expect_content accept_modal_copy
			end

			scenario "accepts tile", js: true do
				within accept_modal do
					click_link "Got it"
				end
				
				#visible_tiles.count.should == 2
				wait_for_ajax
				draft_title.click
				sleep 1
				visible_tiles.count.should == 2
				headline(page.find(:tile, @tile)).should == headline(visible_tiles[0])
			end

			scenario "clicks 'accept', then 'undo' action", js: true do
				page.find(".undo").click
				expect_no_content accept_modal_copy
				draft_title.click
				visible_tiles.count.should == 1
				suggestion_box_title.click
				visible_tiles.count.should == 3
			end
		end

		context "show more button" do
			before do
				# 3 + 5 = 8 user_submitted
				FactoryGirl.create_list :multiple_choice_tile, 5, :user_submitted, demo: demo
				# 1 + 6 = 7 draft
				FactoryGirl.create_list :multiple_choice_tile, 6, :draft, demo: demo
			end

			scenario "expand and minimize suggestion box", js: true do
				visit client_admin_tiles_path
				# in draft section
				visible_tiles.count.should == 6
				show_more_button.click
				visible_tiles.count.should == 7

				suggestion_box_title.click
				# in suggestion box
				visible_tiles.count.should == 6
				show_more_button.click
				visible_tiles.count.should == 8
				show_more_button.click
				visible_tiles.count.should == 6
			end
		end

		context "ignorring process" do
			before do
				# 3 + 1 = 4 user_submitted
				FactoryGirl.create :multiple_choice_tile, :user_submitted, demo: demo
				# 1 ignored
				@ignored_tile = FactoryGirl.create :multiple_choice_tile, :ignored, demo: demo
				visit client_admin_tiles_path(show_suggestion_box: true)
				show_more_button.click

				visible_tiles.count.should == 5
			end

			scenario "ignore tile", js: true do
				tile = submitted_tiles[1]
				ignore_button(tile).click
				wait_for_ajax
				Tile.where(status: Tile::USER_SUBMITTED).count.should == 3
				Tile.where(status: Tile::IGNORED).count.should == 2

				visible_tiles.count.should == 5
				headline(page.find(:tile, tile)).should == headline(ignored_tiles[0])
			end

			scenario "ignore tile", js: true do
				tile = @ignored_tile
				undo_ignore_button(tile).click
				wait_for_ajax
				Tile.where(status: Tile::USER_SUBMITTED).count.should == 5
				Tile.where(status: Tile::IGNORED).count.should == 0

				visible_tiles.count.should == 5
				headline(page.find(:tile, tile)).should == headline(user_submitted_tiles[0])
			end
		end
	end
end
