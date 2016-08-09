require 'acceptance/acceptance_helper'

feature 'User views tiles' do
  def all_tiles_done_message
    "You've finished all new tiles!"
  end

  def tile_row_size(device_type)
    device_type == :mobile ? 2 : 4
  end

  context 'of the multiple-choice variety' do
    before do
      @tile = FactoryGirl.create(:multiple_choice_tile, points: 30)
      @user = FactoryGirl.create(:user, demo: @tile.demo)
      visit tiles_path(as: @user)
    end

    scenario 'and all the stuff around them, including the answer options' do
      expect_supporting_content "This is some extra text by the tile"
      expect_image_credit "by Human"
      expect_question "Which of the following comes out of a bird?"
      expect_points 30
      expect_answer 0, "Ham"
      expect_answer 1, "Eggs"
      expect_answer 2, "A V8 Buick"
    end

    scenario 'and can answer by clicking the answers', js: true do
      click_answer 0
      expect_wrong_answer_reaction 0

      click_answer 2
      expect_wrong_answer_reaction 2

      page.find('.right_multiple_choice_answer').click
      #click_answer 1

      visit activity_path
      expect_content "completed the tile: \"#{@tile.headline}\""
      expect_content "30 PTS"
    end

    scenario 'and sees a helpful message afterwards', js: true do
      page.find('.right_multiple_choice_answer').click
      page.should have_content(all_tiles_done_message)
    end

    scenario "when it's not the first tile navigated to", js: true do
      other_tile = FactoryGirl.create(:tile, demo: @tile.demo, headline: "The tile upon which we will start")
      visit tile_path(other_tile, as: @user)
      page.find('#next').click

      click_answer 0
      expect_wrong_answer_reaction 0

      click_answer 2
      expect_wrong_answer_reaction 2
    end

    context "when there is a short external link" do
      it "should show the whole URL as a link" do
        short_url = "http://www.example.com"
        @tile.update_attributes(link_address: short_url)
        visit tiles_path(as: @user)
        page.all("a[href='#{short_url}'][target=_blank]", text: short_url).should have(1).visible_link
      end
    end

    context "when there is a long external link" do
      it "should show the URL, truncated, as a link" do
        long_url           = "http://www.example.com/abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
        truncated_long_url = "http://www.example.com/abcd..."
        @tile.update_attributes(link_address: long_url)
        visit tiles_path(as: @user)
        page.all("a[href='#{long_url}'][target=_blank]", text: truncated_long_url).should have(1).visible_link
      end
    end
  end

  [[:mobile, 4, 4], [:tablet, 4, 4], [:desktop, 16, 4]].each do |device_type, expected_tile_batch_size, expected_tile_row_size|
    context "loaded in batches which on #{device_type} have #{expected_tile_batch_size} tiles apiece, with a \"See More\" link" do
      before do
        spoof_client_device(device_type)
        @demo = FactoryGirl.create(:demo)
        @user = FactoryGirl.create(:user, demo: @demo, sample_tile_completed: true)

        (expected_tile_batch_size * 2 + 1).times {|n| FactoryGirl.create(:tile, status: 'active', headline: "Tile Number #{n}", demo: @demo)}

        visit activity_path(as: @user)
      end

      it "should show the first #{expected_tile_batch_size} in the first batch", js: true do
        expect_thumbnail_count(expected_tile_batch_size)
      end

      it "should load the next #{expected_tile_batch_size} on clicking See More", js: true do
        show_more_tiles_link.click
        expect_thumbnail_count(expected_tile_batch_size * 2)
        expect_placeholder_count(0)
        expect_show_more_tiles_link_disabled?(false)

        show_more_tiles_link.click
        expect_thumbnail_count(expected_tile_batch_size * 2 + 1)
        expect_placeholder_count(tile_row_size(device_type) - 1)
        expect_show_more_tiles_link_disabled?(true)



        # Hey look, here comes everybody!
        expected_tile_batch_size.times {|n| FactoryGirl.create(:tile, status: 'active', headline: "Second Batch Tile #{n}", demo: @demo)}

        visit activity_path(as: @user)

        show_more_tiles_link.click
        expect_thumbnail_count(expected_tile_batch_size * 2)
        expect_placeholder_count(0)
        expect_show_more_tiles_link_disabled?(false)

        show_more_tiles_link.click
        expect_thumbnail_count(expected_tile_batch_size * 3)
        expect_placeholder_count(0)
        expect_show_more_tiles_link_disabled?(false)

        show_more_tiles_link.click
        expect_thumbnail_count(expected_tile_batch_size * 3 + 1)
        expect_placeholder_count(tile_row_size(device_type) - 1)
        expect_show_more_tiles_link_disabled?(true)
      end
    end
  end
end
