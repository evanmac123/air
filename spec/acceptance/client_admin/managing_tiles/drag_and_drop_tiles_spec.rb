require 'acceptance/acceptance_helper'
feature 'Client admin drags and drops tiles' do
  include TileManagerHelpers
  include WaitForAjax

  let!(:admin) { FactoryGirl.create :client_admin }
  let!(:demo)  { admin.demo  }

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  shared_examples_for 'Moves tile in one section' do |section, tiles_num, i1, i2|
    scenario "#{section} section. Move tile #{tiles_num - i1} on the place of #{tiles_num - i2}", js: true do
      pending "Works in production fails in the test environment FIXME enventuall"
      create_tiles_for_sections section => tiles_num
      visit current_path #reload page
      tiles = demo.send(:"#{section}_tiles").to_a
      t1, t2 = tiles[i1], tiles[i2]
      move_tile t1, t2

      wait_for_ajax
      tile_id = tiles[i1].id
      tiles.insert i2, tiles.delete_at(i1)
      section_tile_headlines("##{section}").should == tiles.map(&:headline)
      demo.reload.send(:"#{section}_tiles").should == tiles
    end
  end

  shared_examples_for 'Moves tile between sections' do |section1, num1, i1, section2, num2, i2|
    scenario "Move tile #{num1 - i1} from #{section1} to tile #{num2 - i2} in #{section2}", js: true do
      pending "Works in production fails in the test environment FIXME enventually. Weird logic for tests. Tests should be simple to understand! No sends!!"
      create_tiles_for_sections section1 => num1, section2 => num2
      tiles1 = demo.send(:"#{section1}_tiles").to_a
      tiles2 = demo.send(:"#{section2}_tiles").to_a
      visit current_path
      move_tile_between_sections tiles1[i1], tiles2[i2]

      tiles2.insert i2, tiles1.delete_at(i1)
      wait_for_ajax

      expect(section_tile_headlines("##{section1}")).to eq(tiles1.map(&:headline))
      expect(section_tile_headlines("##{section2}")).to eq(tiles2.map(&:headline))

      expect(demo.reload.send(:"#{section1}_tiles")).to eq(tiles1)
      expect(demo.reload.send(:"#{section2}_tiles")).to eq(tiles2)
    end
  end

  shared_examples_for "Tile is loaded after drag and drop if needed" do |section1, section2|
    scenario "After moving tile from #{section1} to #{section2}", js: true do
      create_tiles_for_sections section1 => 5, section2 => 1
      i1 = 3
      i2 = 0
      tiles1 = demo.send(:"#{section1}_tiles").to_a
      tiles2 = demo.send(:"#{section2}_tiles").to_a

      visit current_path
      expect_no_content tiles1[i1 + 1].headline
      move_tile_between_sections tiles1[0], tiles2[i2]

      wait_for_ajax
      section_tile_headlines("##{section1}").last.should == tiles1[i1 + 1].headline
    end
  end

  context "Moves tiles on Manage Page" do
    before(:each) do
      visit client_admin_tiles_path
    end

    it_should_behave_like "Moves tile in one section", "draft",   3, 1, 0
    it_should_behave_like "Moves tile in one section", "active",  5, 1, 3
    it_should_behave_like "Moves tile in one section", "archive", 4, 0, 2

    it_should_behave_like "Moves tile between sections", "active",  7, 2, "draft",   2, 1

    it_should_behave_like "Moves tile between sections", "archive", 4, 3, "draft",   2, 1
    it_should_behave_like "Moves tile between sections", "archive", 4, 2, "active",  3, 2

    it_should_behave_like "Tile is loaded after drag and drop if needed", "archive", "active"
    it_should_behave_like "Tile is loaded after drag and drop if needed", "archive", "draft"

    context "Move Confirmation Modal when user moves tile from archive to active" do
      before do
        @section1, @num1, @i1 = "archive", 4, 3
        @section2, @num2, @i2 = "active", 3, 2
        create_tiles_for_sections @section1 => @num1, @section2 => @num2
        @tiles1 = demo.send(:"#{@section1}_tiles").to_a
        @tiles2 = demo.send(:"#{@section2}_tiles").to_a
      end

      it "should not show modal if tile has no completions", js: true do
        pending "Works in production fails in the test environment FIXME enventuall"
        visit current_path
        move_tile_between_sections @tiles1[@i1], @tiles2[@i2]

        expect_no_content move_modal_text

        @tiles2.insert @i2, @tiles1.delete_at(@i1)
        wait_for_ajax

        expect(section_tile_headlines("##{@section1}")).to eq(@tiles1.map(&:headline))
        expect(section_tile_headlines("##{@section2}")).to eq(@tiles2.map(&:headline))

        expect(demo.reload.send(:"#{@section1}_tiles")).to eq(@tiles1)
        expect(demo.reload.send(:"#{@section2}_tiles")).to eq(@tiles2)
      end

      it "should show modal if tile has completions", js: true do
        FactoryGirl.create :tile_completion, user: admin, tile: @tiles1[@i1]
        visit current_path
        move_tile_between_sections @tiles1[@i1], @tiles2[@i2]

        expect(page).to have_content(move_modal_text)
      end
    end
  end

  context "Moves tiles on Inactive Tiles Page" do
    before(:each) { visit client_admin_inactive_tiles_path }
    it_should_behave_like "Moves tile in one section", "archive", 4, 0, 2
  end

  def move_modal_text
    "If you want to re-use the content, please create a new Tile."
  end
end
