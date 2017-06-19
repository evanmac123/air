module TilePreviewHelpers
  def click_copy_button
    page.find('.copy_to_board').click
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
      expect(copied_tile[expected_same_field]).to eq(original_tile[expected_same_field])
    end

    expect(copied_tile.creator.name).to eq(copying_user.name)
    expect(copied_tile.status).to eq(Tile::DRAFT)
    expect(copied_tile.demo_id).to eq(copying_user.demo_id)
    expect(copied_tile.is_public).to be_falsey

    expect(copied_tile.image_updated_at).to be_present
    expect(copied_tile.thumbnail_updated_at).to be_present
    expect(copied_tile.image_file_name).to eq(original_tile.image_file_name)
    expect(copied_tile.thumbnail_file_name).to eq(original_tile.thumbnail_file_name)
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
