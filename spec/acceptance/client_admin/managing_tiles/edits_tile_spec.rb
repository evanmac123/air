require 'acceptance/acceptance_helper'


shared_examples_for "editing a tile" do
  def click_update_button
    click_button "Update tile"
  end
  scenario 'should see the tile image before editing' do
    page.find("img[src='#{@tile.reload.image}']").should be_present
  end

  scenario 'changing the image', js: true do
    attach_tile "tile_builder_form[image]", tile_fixture_path('cov1.jpg')
    click_button "Update tile"

    Tile.count.should == 1
    @tile.reload.image_file_name.should == 'cov1.jpg'

    should_be_on client_admin_tile_path(@tile)
    expect_content after_tile_save_message(hide_activate_link: true, action: "update")
  end

  scenario "clear the image", js: true do
    show_tile_image
    page.find(".clear_image").click
    show_tile_image_placeholder
  end

  scenario "clear the image and try to update tile, \
            cancel and see old image again", js: true do
    page.find(".clear_image").click
    click_button "Update tile"

    should_be_on client_admin_tile_path(@tile)
    expect_content "You can't save a tile without an image. Add a new image or click cancel to restore the image you removed"
    show_tile_image_placeholder
    page.find(".flash-content a").click #cancel link in flash
    should_be_on client_admin_tile_path(@tile)
    page.find("img[src='#{@tile.reload.image}']").should be_present
  end

  scenario "upload new image and update tile", js: true do
    original_image_file_name = @tile.image_file_name
    attach_tile "tile_builder_form[image]", tile_fixture_path('cov2.jpg')
    click_button "Update tile"

    Tile.count.should == 1
    @tile.reload.image_file_name.should_not == original_image_file_name
    @tile.reload.image_file_name.should == 'cov2.jpg'
    expect_content after_tile_save_message(action: "update")
  end

  scenario "upload new image but make empty fields, click update tile\
            see new image and error message, fill empty fields, \
            save tile and get new image", js:true do
    
    fill_in "Headline", with: ""
    attach_tile "tile_builder_form[image]", tile_fixture_path('cov2.jpg')
    click_button "Update tile"

    expect_content "Sorry, we couldn't update this tile"
    click_add_answer
    fill_in_answer_field 0, "yes"
    fill_in "Headline", with: "head"
    click_button "Update tile"

    should_be_on client_admin_tile_path(@tile)
    expect_content after_tile_save_message(action: "update")
    @tile.reload.image_file_name.should == 'cov2.jpg'
  end

  scenario "won't let the user blank out the last answer", js: true do
    0.upto(page.all(answer_link_selector).count - 1).each {|n| fill_in_answer_field n, ""}
    click_button "Update tile"

    expect_content "Sorry, we couldn't update this tile: must have at least one answer"
  end 
end

feature "Client admin edits tile" do
  def fill_in_fields
    fill_in_image_credit "by Me"
    fill_in "Headline",           with: "Ten pounds of cheese"
    fill_in "Supporting content", with: "Ten pounds of cheese. Yes? Or no?"

    fill_in_question "Who rules?"


    5.times {click_add_answer}

    # Blank out "value 0"...
    fill_in_answer_field 0, "it"

    # ...leave "value 1" alone, overwrite "value 2"...
    fill_in_answer_field 2, "you"

    # ...and add two brand-new values.
    fill_in_answer_field 3, "me"
    fill_in_answer_field 4, "bob"

    fill_in_points "18"

    fill_in_external_link_field "http://example.co.uk"
  end


  context "multiple choice tile" do
    before do
      @tile = FactoryGirl.create :multiple_choice_tile
      crank_dj_clear

      @client_admin = FactoryGirl.create(:client_admin, demo: @tile.demo)
      visit edit_client_admin_tile_path(@tile, as: @client_admin)
    end

    it_should_behave_like "editing a tile"

    scenario "remembers the correct answer index", js: true do
      page.find(".clicked_right_answer").should be_present
    end

    scenario "changing the regular fields", js: true do
      fill_in_fields
      select_correct_answer 2
      click_button "Update tile"

      @tile.reload
      @tile.image_credit.should == "by Me"
      @tile.headline.should == "Ten pounds of cheese"
      @tile.supporting_content.should == "Ten pounds of cheese. Yes? Or no?"
      @tile.question.should == "Who rules?"
      @tile.link_address.should == "http://example.co.uk"

      @tile.multiple_choice_answers.should == ["it", "Eggs", "you", "me", "bob", "Add Answer Option"]
      @tile.correct_answer_index.should == 2
      should_be_on client_admin_tile_path(@tile)
      expect_content after_tile_save_message(hide_activate_link: true, action: "update")
    end

    scenario "with bad information", js: true do
      fill_in "Headline",           with: ""
      fill_in "Supporting content", with: ""

      fill_in_question ""
      
      click_button "Update tile"
      expect_content "Sorry, we couldn't update this tile: headline can't be blank, supporting content can't be blank, question can't be blank."
    end

    context "using image library" do
      before do
        @tile_images = FactoryGirl.create_list :tile_image, 3
        crank_dj_clear
        visit edit_client_admin_tile_path(@tile, as: @client_admin)
      end

      scenario "takes image from image library", js: true do
        tile_image_block(@tile_images[0]).click
        click_button "Update tile"


        Tile.count.should == 1
        tile = Tile.first

        should_be_on client_admin_tile_path(tile)
        expect_content after_tile_save_message(hide_activate_link: true, action: "update")
        tile.image_file_name.should == @tile_images[0].image_file_name
      end
    end
  end
end
