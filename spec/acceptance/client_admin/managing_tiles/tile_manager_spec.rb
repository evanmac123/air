require 'acceptance/acceptance_helper'

feature 'Client admin and tile manager page', js: true do
  include TileManagerHelpers

  let(:admin) { FactoryBot.create :client_admin }
  let(:demo)  { admin.demo  }

  before(:each) do
    signin_as(admin, admin.password)
  end

  context 'No tiles exist for any of the types' do

    before(:each) { visit(client_admin_tiles_path) }

    scenario 'Correct message is displayed when there are no Active tiles' do
      expect(page.find("#active .no_tiles_section", visible: true)).to be_present
      expect(page).to have_num_tiles(0)
    end

    scenario 'Correct message is displayed when there are no Archive tiles' do
      expect(page.find("#active .no_tiles_section", visible: true)).to be_present
      expect(page).to have_num_tiles(0)
    end
  end

  context 'Tiles exist for each of the types' do
    let(:first)        { create_tile headline: 'first headline'  }
    let(:second)       { create_tile headline: 'second headline' }
    let(:third) { create_tile headline: 'third headline' }

    let!(:tiles) { [first, second, third] }

    scenario "The tile content is correct for Active tiles" do
      tiles.each { |tile| tile.update_attributes status: Tile::ACTIVE }

      visit(client_admin_tiles_path)

      expect(active_tab).to have_num_tiles(3)

      within active_tab do
        tiles.each do |tile|
          within ".tile_thumbnail[data-tile-id='#{tile.id}']" do
            expect_content tile.headline
            expect(page).to have_css "a[data-status='archive']", visible: false
            expect(page).to have_css "li.edit_button a", visible: false
          end
        end
      end
    end

    scenario "The tile content is correct for Archive tiles" do
      tiles.each { |tile| tile.update_attributes status: Tile::ARCHIVE }

      visit(client_admin_tiles_path)

      expect(page).to have_num_tiles(3)

      tiles.each do |tile|
        within ".tile_thumbnail[data-tile-id='#{tile.id}']" do
          expect_content tile.headline
          expect(page).to have_css "a[data-status='active']", visible: false
          expect(page).to have_css "li.edit_button a", visible: false
        end
      end
    end

    context 'Archiving and activating tiles' do
      scenario "The 'Archive this tile' links work, including setting the 'archived_at' time and positioning most-recently-archived tiles first" do
        tiles.each { |tile| tile.update_attributes status: Tile::ACTIVE }
        visit(client_admin_tiles_path)
        expect(active_tab).to  have_num_tiles(3)
        expect(archive_tab).to have_num_tiles(0)

        active_tab.find(".tile_thumbnail[data-tile-id='#{first.id}']").hover
        page.find("a", text: "Archive", visible: true).click


        within(active_tab)  { expect(page).not_to contain first.headline }
        within(archive_tab) { expect(page).to     contain first.headline }

        expect(active_tab).to  have_num_tiles(2)
        expect(archive_tab).to have_num_tiles(1)
        # Do it one more time to make sure that the most-recently archived tile appears first in the list
        #second.archived_at.should be_nil
        #FIXME we should be able to assert in model or controller spec or js
        #test that the order of tiles is correct
        active_tab.find(".tile_thumbnail[data-tile-id='#{second.id}']").hover
        page.find("a", text: "Archive", visible: true).click


        within(active_tab)  { expect(page).not_to contain second.headline }
        within(archive_tab) { expect(page).to     contain second.headline }

        expect(active_tab).to  have_num_tiles(1)
        expect(archive_tab).to have_num_tiles(2)

        expect(archive_tab).to have_first_tile(second, Tile::ARCHIVE)
      end
    end
  end

  context "New client admin visits client_admin/tiles page" do
    context "when there is atleast one activated tile in demo", js: true do
      before do
        @tile = FactoryBot.create :tile, demo: admin.demo, status: Tile::ACTIVE, creator: admin
        FactoryBot.create :tile, demo: admin.demo, status: Tile::ACTIVE, creator: admin
        visit(client_admin_tiles_path)
      end

      scenario "count appears near share link indicating the number tiles to be shared" do
        within('#share_tiles') do
          #in this scenario, one tile is created in 'before do' so the number
          #of tiles to be shared should be one
          expect(page).to have_content("2")
        end
      end
    end
  end

  describe 'Tiles appear in reverse-chronological order by activation/archived-date and then creation-date' do
    # Chronologically-speaking, creating tiles "up" from 0 to 10 and then checking "down" from 10 to 0
    let!(:tiles) do
      10.times do |i|
        tile = FactoryBot.create :tile, demo: demo, headline: "Tile #{i}", created_at: Time.current + i.days
        # We now sort by activated_at/archived_at, and if those times aren't present we fall back on created_at
        # Make it so that all odd tiles should be listed before all even ones, and that odd/even each should be sorted in descending order.
        if i.even?
          awhile_ago = tile.created_at - 2.weeks
          tile.update_attributes(activated_at: awhile_ago, archived_at: awhile_ago)
        end
      end
    end
  end

  it "has a button that you can click on to create a new tile" do
    visit(client_admin_tiles_path)
    click_add_new_tile
  end

  it "pads odd rows, in both the inactive and active sections, with blank placeholder cells, so the table comes out right", js: true do

    # 1 tile, 6 places in row, so
    FactoryBot.create_list(:tile, 1, :draft, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_draft_tile_placeholders(5)

    FactoryBot.create_list(:tile, 3, :draft, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_draft_tile_placeholders(2)

    FactoryBot.create(:tile, :draft, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_draft_tile_placeholders(1)

    FactoryBot.create(:tile, :draft, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_draft_tile_placeholders(0)

     # There's now the creation placeholder, plus 4 other draft tiles.
    # If we DID show all of them, there's be an odd row with 1 tile, and we'd
    # expect 3 placeholders. But we only show the first 4 draft tiles
    # (really the first 3 + creation placeholder) and those two rows are full
    # now, so...
    FactoryBot.create(:tile, :draft, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_draft_tile_placeholders(0)

    # And now let's do the active ones
    expect_active_tile_placeholders(0)

    FactoryBot.create(:tile, :active, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_active_tile_placeholders(3)

    FactoryBot.create(:tile, :active, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_active_tile_placeholders(2)

    FactoryBot.create(:tile, :active, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_active_tile_placeholders(1)

    FactoryBot.create(:tile, :active, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_active_tile_placeholders(0)

    FactoryBot.create(:tile, :active, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_active_tile_placeholders(3)

    #And now let's look at archived sction(It's similiar to active)
    expect_inactive_tile_placeholders(0)

    FactoryBot.create(:tile, :archived, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_inactive_tile_placeholders(3)

    FactoryBot.create(:tile, :archived, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_inactive_tile_placeholders(2)

    FactoryBot.create(:tile, :archived, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_inactive_tile_placeholders(1)

    FactoryBot.create(:tile, :archived, demo: admin.demo)
    visit(client_admin_tiles_path)
    expect_inactive_tile_placeholders(0)
    5.times { FactoryBot.create(:tile, :archived, demo: admin.demo) }

    # There's now the creation placeholder, plus eight other archived tiles.
    # If we DID show all of them, there's be an odd row with 1 tile, and we'd
    # expect 3 placeholders. But we only show the first 8 archive tiles
    # and those two rows are full
    # now, so...
    visit(client_admin_tiles_path)
    expect_inactive_tile_placeholders(0)

    # And now let's look at the full megillah of archived tiles
    visit client_admin_inactive_tiles_path
    expect_inactive_tile_placeholders(3)

    Tile.archive.last.destroy
    visit client_admin_inactive_tiles_path
    expect_inactive_tile_placeholders(0)

    Tile.archive.last.destroy
    visit client_admin_inactive_tiles_path
    expect_inactive_tile_placeholders(1)

    Tile.archive.last.destroy
    visit client_admin_inactive_tiles_path
    expect_inactive_tile_placeholders(2)

    Tile.archive.last.destroy
    visit client_admin_inactive_tiles_path
    expect_inactive_tile_placeholders(3)
  end
end
