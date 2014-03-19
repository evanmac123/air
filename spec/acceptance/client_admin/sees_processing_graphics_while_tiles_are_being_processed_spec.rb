require 'acceptance/acceptance_helper'

feature 'Sees processing graphics while tiles are being processed' do
  def create_tile(admin=a_client_admin)
    visit new_client_admin_tile_path(as: admin)
    attach_tile "tile_builder_form[image]", tile_fixture_path('cov1.jpg')
    fill_in "Headline",           with: "Ten pounds of cheese"
    fill_in "Supporting content", with: "Ten pounds of cheese. Yes? Or no?"

    fill_in "Ask a question", with: "Who rules?"

    fill_in_answer_field 0, "Me"
    fill_in_answer_field 1, "You"
    select_correct_answer 0

    fill_in "Points", with: "23"

    click_button "Save tile"
  end

  it 'shows the processing graphic, until the real one is ready', js: true do
    create_tile
    page.find('.tile_image')['src'].should == Tile::IMAGE_PROCESSING_IMAGE_URL

    crank_dj_clear
    sleep(ClientAdmin::ImagesController::IMAGE_POLL_DELAY + 1)

    page.find('.tile_image')['src'].should include('cov1.png')
  end

  it 'shows the processing after updating a tile, until the real one is ready', js: true do
    create_tile
    crank_dj_clear

    tile = Tile.last
    visit edit_client_admin_tile_path(tile)

    page.find('.tile_image')['src'].should include('cov1.png')

    attach_tile "tile_builder_form[image]", tile_fixture_path('cov2.jpg')
    click_button "Update tile"

    page.find('.tile_image')['src'].should == Tile::IMAGE_PROCESSING_IMAGE_URL

    crank_dj_clear
    sleep(ClientAdmin::ImagesController::IMAGE_POLL_DELAY + 1)

    page.find('.tile_image')['src'].should include('cov2.png')
  end

  it 'shows the processing thumbnail, until the real one is ready', js: true do
    admin = FactoryGirl.create(:client_admin)
    2.times {create_tile(admin)}
    visit client_admin_tiles_path

    draft_tiles = page.all("td.draft")
    draft_tiles.should have(2).tiles
    draft_tiles.each {|draft_tile| draft_tile.find('img')['src'].should == Tile::THUMBNAIL_PROCESSING_IMAGE_URL}

    crank_dj_clear
    sleep(ThumbnailsController::THUMBNAIL_POLL_DELAY + 1)

    draft_tiles.each {|draft_tile| draft_tile.find('img')['src'].should include("cov1.png")}
  end

  it 'should handle the case where some thumbnails finish processing before others properly', js: true do
    admin = FactoryGirl.create(:client_admin)
    2.times {create_tile(admin)}
    visit client_admin_tiles_path

    draft_tiles = page.all("td.draft")
    draft_tiles.should have(2).tiles
    draft_tiles.each {|draft_tile| draft_tile.find('img')['src'].should == Tile::THUMBNAIL_PROCESSING_IMAGE_URL}

    # We should have two jobs for each new tile (one for the image, one for
    # the thumbnail, so we'll find the jobs corresponding to one tile, and
    # tweak their run_at so they won't get processed just yet.

    jobs_to_postpone = Delayed::Job.where("handler LIKE '%instance_id: #{Tile.last.id}%'")
    jobs_to_postpone.each {|dj| dj.run_at = Time.now + 10.years; dj.save!}
    crank_dj_clear
    sleep(ThumbnailsController::THUMBNAIL_POLL_DELAY + 1)

    image_sources = draft_tiles.map {|draft_tile| draft_tile.find('img')['src']}
    image_sources.should have(2).urls
    image_sources.should include(Tile::THUMBNAIL_PROCESSING_IMAGE_URL)
    image_sources.reject{|image_source| image_source == Tile::THUMBNAIL_PROCESSING_IMAGE_URL}.first.should include('cov1.png')

    # One's done, the other is not. Now let's have the slowcoach catch up.
    jobs_to_postpone.each {|dj| dj.run_at = Time.now - 5.seconds; dj.save!}
    crank_dj_clear
    sleep(ThumbnailsController::THUMBNAIL_POLL_DELAY + 1)
    draft_tiles.each {|draft_tile| draft_tile.find('img')['src'].should include('cov1.png')}
  end
end
