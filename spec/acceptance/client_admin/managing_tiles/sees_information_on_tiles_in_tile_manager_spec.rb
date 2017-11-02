require 'acceptance/acceptance_helper'

feature 'Sees helpful information in tile manager' do
  let (:demo)         { FactoryGirl.create :demo }
  let (:client_admin) { FactoryGirl.create :client_admin, demo: demo }

  def tile_cell(tile)
    "[data-tile_id='#{tile.id}']"  
  end

  def complete_tile tile
    expect_content tile.headline
    page.find('.multiple-choice-answer.correct').click
  end

  def tile_stat tile, selector
    full_selector = tile_cell(tile) + " " + selector
    page.find(full_selector).text
  end

  def activation_date tile
    tile_stat tile, ".activation_dates"
  end

  def unique_views tile
    tile_stat(tile, ".unique_views").to_i
  end

  def total_views tile
    tile_stat(tile, ".views").to_i
  end

  def completions tile
    tile_stat(tile, ".completions").to_i
  end

  before do
    skip
  end

  after do
    Timecop.return
  end

  context "for a tile in the archive that has never been activated", js: true do
    it "should say so" do
      tile = FactoryGirl.create(:tile, demo: demo, status: Tile::ARCHIVE)
      expect(tile.activated_at).to be_nil
      expect(tile.archived_at).not_to be_nil

      visit client_admin_tiles_path(as: client_admin)

      expect(activation_date(tile)).to eq("0")
    end
  end

  context "for a tile in the archive that was at one point active" do
    before do
      Timecop.travel(7.days)
      @tile = FactoryGirl.create(:tile, demo: demo, status: Tile::ARCHIVE, activated_at: 7.days.ago)

      visit client_admin_tiles_path(as: client_admin)
    end

    it "should show the length of time that it was active", js: true do
      expect(activation_date(@tile)).to eq("7 days")
    end

    it "should show tile views", js: true do
      expect(total_views(@tile)).to eq(0)
      expect(unique_views(@tile)).to eq(0)

      2.times { FactoryGirl.create :tile_viewing, tile: @tile }
      visit client_admin_tiles_path

      expect(total_views(@tile)).to eq(2)
      expect(unique_views(@tile)).to eq(2)
    end
  end

  context "for a tile that is active" do
    context "info about activation" do
      before do
        Timecop.travel(7.days)
        @tile = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE, activated_at: 7.days.ago, archived_at: 19.days.ago)

        visit client_admin_tiles_path(as: client_admin)
      end

      it "should show the length of time that it's been active", js: true do
        expect(activation_date(@tile)).to eq("7 days")
      end
    end

    context "info about views" do
      before do
        @tile1 = FactoryGirl.create(:multiple_choice_tile, demo: demo, status: Tile::ACTIVE, activated_at: 7.days.ago)
        @tile2 = FactoryGirl.create(:multiple_choice_tile, demo: demo, status: Tile::ACTIVE, activated_at: 7.days.ago)
      end

      it "should have no views initially" do
        visit client_admin_tiles_path(as: client_admin)

        expect(total_views(@tile1)).to eq(0)
        expect(total_views(@tile2)).to eq(0)

        expect(unique_views(@tile1)).to eq(0)
        expect(unique_views(@tile2)).to eq(0)
      end

      it "should count user's views when he completes and views tiles", js: true do
        #
        # => Completes tiles
        #
        visit tiles_path(as: client_admin)
        
        complete_tile @tile2
        complete_tile @tile1

        expect_content "Return to homepage"

        visit client_admin_tiles_path(as: client_admin)

        expect(total_views(@tile2)).to eq(1)

        expect(unique_views(@tile1)).to eq(1)
        expect(unique_views(@tile2)).to eq(1)
        #
        # => Views tiles
        #
        visit tile_path(@tile2, as: client_admin)

        expect_content @tile2.headline
        show_next_tile

        expect_content @tile1.headline
        show_next_tile

        expect_content @tile2.headline

        visit client_admin_tiles_path

        expect(total_views(@tile1)).to eq(2)
        expect(total_views(@tile2)).to eq(3)

        expect(unique_views(@tile1)).to eq(1)
        expect(unique_views(@tile2)).to eq(1)
      end

      it "should count guest user's views when he views completed tiles", js: true do
        guest_user = a_guest_user
        #
        # => Completes tiles
        #
        visit public_tiles_path(public_slug: demo.public_slug, as: guest_user)
        
        complete_tile @tile2
        complete_tile @tile1

        expect_content "Return to homepage"
        #
        # => Views tiles
        #
        visit public_tile_path(id: @tile2, public_slug: demo.public_slug, as: guest_user)

        close_conversion_form

        expect_content @tile2.headline
        show_next_tile

        close_conversion_form

        expect_content @tile1.headline
        show_next_tile

        expect_content @tile2.headline

        visit client_admin_tiles_path(as: client_admin)

        expect(total_views(@tile1)).to eq(2)
        expect(total_views(@tile2)).to eq(3)

        expect(unique_views(@tile1)).to eq(1)
        expect(unique_views(@tile2)).to eq(1)
      end
    end
  end

  context "with information about completed tiles" do
    before do
      @tile_1 = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE,  archived_at: 5.days.ago, activated_at: 2.days.ago)
      @tile_2 = FactoryGirl.create(:tile, demo: demo, status: Tile::ARCHIVE, archived_at: 5.days.ago, activated_at: 6.days.ago)
      @tile_3 = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE,  archived_at: 5.days.ago, activated_at: 2.days.ago)
      @tile_4 = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE,  archived_at: 5.days.ago, activated_at: 2.days.ago)

      1.times {FactoryGirl.create(:tile_completion, tile: @tile_1)}
      2.times {FactoryGirl.create(:tile_completion, tile: @tile_2)}
      3.times {FactoryGirl.create(:tile_completion, tile: @tile_3)}

      [@tile_1, @tile_2, @tile_3].each do |tile|
        tile.tile_completions.map(&:user).each {|user| user.add_board(demo.id)}
        tile.tile_completions.first.user.update_attributes(accepted_invitation_at: Time.current)
      end

      visit client_admin_tiles_path(as: client_admin)
    end

    it "such as the number of users who have completed the tile" do
      expect(completions(@tile_1)).to eq(1)
      expect(completions(@tile_2)).to eq(2)
      expect(completions(@tile_3)).to eq(3)
      expect(completions(@tile_4)).to eq(0)
    end
  end
end
