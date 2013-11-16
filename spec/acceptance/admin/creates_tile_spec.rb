require 'acceptance/acceptance_helper'

feature 'Site-Admin creates tiles with start and end times, and they play nice with activating and archiving' do
  # Need to link these guys together so that the tiles appear when you go from the site-admin to the client-admin page
  let (:site_admin) { FactoryGirl.create(:site_admin)}
  let (:demo)       { site_admin.demo }

  def create_new_tile(options = {})
    fill_in "Headline", with: "Killing Kittens"

    fill_in("Start time", with: options[:start_time]) if options.has_key?(:start_time)
    fill_in("End time",   with: options[:end_time])   if options.has_key?(:end_time)

    attach_file "tile[image]",     tile_fixture_path('cov1.jpg')
    attach_file "tile[thumbnail]", tile_fixture_path('cov1_thumbnail.jpg')

    click_button "Create Tile"
  end

  # Don't use the 'an_admin' helper for 'as:' because no tiles will show up; need to create a 'site_admin' associated with this 'demo'
  before do
    visit new_admin_demo_tile_path(demo, as: site_admin)
  end

  scenario "A tile has 'active' status if a start time is not present, and it appears in the right spot in the Active tab" do
    create_existing_tiles(demo, Tile::ACTIVE, 2)

    create_new_tile end_time: Date.tomorrow.to_s  # Produces something like "2013-07-21"
    page.should contain('New tile created')

    visit tile_manager_page

    active_tab.should have_num_tiles(3)
    active_tab.should have_first_tile(Tile.last, Tile::ACTIVE)

    # Tile just landed in the 'Active' tab => Check that it is also in the 'Digest' one
    visit client_admin_share_path
    page.should have_num_tiles(3)
    page.should have_first_tile(Tile.last, 'digest')
  end

  scenario "A tile has 'archive' status if a start time is present, and it appears in the right spot in the Archive tab" do
    create_existing_tiles(demo, Tile::ARCHIVE, 2)

    create_new_tile start_time: Date.tomorrow.to_s  # Produces something like "2013-07-21"
    page.should contain('New tile created')

    visit tile_manager_page

    archive_tab.should have_num_tiles(3)
    archive_tab.should have_first_tile(Tile.last, Tile::ARCHIVE)

    visit client_admin_share_path
    page.should have_num_tiles(0)
  end

  scenario "A tile with a 'start_time' and 'end_time' gets activated and archived at the right times" do
    create_existing_tiles(demo, Tile::ACTIVE, 2)
    create_existing_tiles(demo, Tile::ARCHIVE, 2)

    create_new_tile start_time: (Date.today + 1.day).to_s, end_time: (Date.today + 2.days).to_s
    page.should contain('New tile created')

    visit tile_manager_page

    active_tab.should have_num_tiles(2)
    archive_tab.should have_num_tiles(3)
    archive_tab.should have_first_tile(Tile.last, Tile::ARCHIVE)

    visit client_admin_share_path
    page.should have_num_tiles(2)

    # Believe it or not, 1 day later the site has logged you out => Need to do the following (instead of 'visit tile_manager_page')
    Timecop.travel((Date.today + 1.day + 1.minute).to_time)
    visit client_admin_tiles_path(as: site_admin)

    active_tab.should have_num_tiles(3)
    archive_tab.should have_num_tiles(2)
    active_tab.should have_first_tile(Tile.last, Tile::ACTIVE)

    # Tile just landed in the 'Active' tab => Check that it is also in the 'Digest' one
    visit client_admin_share_path
    page.should have_num_tiles(3)
    page.should have_first_tile(Tile.last, 'digest')

    Timecop.travel((Date.today + 2.days + 1.minute).to_time)
    visit client_admin_tiles_path(as: site_admin)

    archive_tab.should have_num_tiles(3)
    active_tab.should have_num_tiles(2)
    archive_tab.should have_first_tile(Tile.last, Tile::ARCHIVE)

    visit client_admin_share_path
    page.should have_num_tiles(2)

    Timecop.return
  end

  scenario "When a tile with a 'start_time' gets activated and the admin archives it, it stays archived" do
    create_existing_tiles(demo, Tile::ACTIVE, 2)
    create_existing_tiles(demo, Tile::ARCHIVE, 2)

    create_new_tile start_time: (Date.today + 1.day).to_s
    page.should contain('New tile created')

    visit tile_manager_page

    active_tab.should have_num_tiles(2)
    archive_tab.should have_num_tiles(3)

    Timecop.travel((Date.today + 1.day + 1.minute).to_time)
    visit client_admin_tiles_path(as: site_admin)

    active_tab.should have_num_tiles(3)
    archive_tab.should have_num_tiles(2)

    active_tab.find(:tile, Tile.last).click_link('Deactivate')
    page.should contain "The Killing Kittens tile has been archived"

    active_tab.should have_num_tiles(2)
    archive_tab.should have_num_tiles(3)

    visit tile_manager_page

    active_tab.should have_num_tiles(2)
    archive_tab.should have_num_tiles(3)

    Timecop.return
  end

  scenario "When a tile with an 'end_time' gets archived and the admin activates it, it stays activated" do
    create_existing_tiles(demo, Tile::ACTIVE, 2)
    create_existing_tiles(demo, Tile::ARCHIVE, 2)

    create_new_tile end_time: (Date.today + 1.day).to_s
    page.should contain('New tile created')

    visit tile_manager_page

    active_tab.should have_num_tiles(3)
    archive_tab.should have_num_tiles(2)

    Timecop.travel((Date.today + 1.day + 1.minute).to_time)
    visit client_admin_tiles_path(as: site_admin)

    active_tab.should have_num_tiles(2)
    archive_tab.should have_num_tiles(3)

    archive_tab.find(:tile, Tile.last).click_link('Activate')
    page.should contain "The Killing Kittens tile has been activated"

    active_tab.should have_num_tiles(3)
    archive_tab.should have_num_tiles(2)

    visit tile_manager_page

    active_tab.should have_num_tiles(3)
    archive_tab.should have_num_tiles(2)

    Timecop.return
  end
end
