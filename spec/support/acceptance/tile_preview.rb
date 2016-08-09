module TilePreviewHelpers
  def expect_copied_lightbox
    page.find(".tile_copied_lightbox")
    expect(page).to have_content("Tile has been copied to your board's drafts section.")
  end

  def click_copy_button
    page.find('.copy_to_board').click
    register_if_guest
    expect_copied_lightbox

    within '.tile_copied_lightbox' do
      click_button "OK"
    end
  end

  def click_copy_link
    page.first('.copy_tile_link').click
    expect_copied_lightbox
  end

  def click_like
    first('.not_like_button').click
  end

  def click_unlike_link_in_preview
    page.find(:xpath,"//div[contains(@class,'like-button')]/a[2]").click
  end

  def click_unlike_link
    page.first('.tile_liked a').click
  end

  def newest_tile
    Tile.order("updated_at DESC").first
  end

  def click_tile
    page.find(:xpath,"//div[contains(@class,'tile_image')]/a").click
  end

  def expect_tile_copied(original_tile, copying_user)
    copied_tile = newest_tile

    %w(correct_answer_index headline image_content_type link_address multiple_choice_answers points question supporting_content thumbnail_content_type type).each do |expected_same_field|
      Rails.logger.info("!! tile copy field : #{expected_same_field}")
      copied_tile[expected_same_field].should == original_tile[expected_same_field]
    end

    copied_tile.creator.name.should == copying_user.name
    copied_tile.status.should == Tile::DRAFT
    copied_tile.demo_id.should == copying_user.demo_id
    copied_tile.is_copyable.should be_false
    copied_tile.is_public.should be_false

    copied_tile.image_updated_at.should be_present
    copied_tile.thumbnail_updated_at.should be_present
    copied_tile.image_file_name.should == original_tile.image_file_name
    copied_tile.thumbnail_file_name.should == original_tile.thumbnail_file_name
  end

  def upvote_tutorial_content
    "Like a tile? Vote it up to give the creator positive feedback."
  end

  def share_link_tutorial_content
    "Want to share a tile? Email it using the email icon. Or, share to your social networks using the LinkedIn icon or copying the link."
  end

  def click_next_intro_link
    page.find('.introjs-nextbutton').click
  end
end
