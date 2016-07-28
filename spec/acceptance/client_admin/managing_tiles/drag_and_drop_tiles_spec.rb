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

  before do
    pending
  end

  shared_examples_for 'Moves tile in one section' do |section, tiles_num, i1, i2|
    scenario "#{section} section. Move tile #{tiles_num - i1} on the place of #{tiles_num - i2}", js: true do
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
    scenario "Move tile #{num1 - i1} from #{section1} to tile #{num2 - i2} in #{section2}", js: true do#, driver: :webkit do
      create_tiles_for_sections section1 => num1, section2 => num2
      tiles1 = demo.send(:"#{section1}_tiles").to_a
      tiles2 = demo.send(:"#{section2}_tiles").to_a
      visit current_path
      move_tile_between_sections tiles1[i1], tiles2[i2]

      tiles2.insert i2, tiles1.delete_at(i1)
      wait_for_ajax

      section_tile_headlines("##{section1}").should == tiles1.map(&:headline)
      section_tile_headlines("##{section2}").should == tiles2.map(&:headline)

      demo.reload.send(:"#{section1}_tiles").should == tiles1
      demo.reload.send(:"#{section2}_tiles").should == tiles2
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
    before(:each) { visit client_admin_tiles_path }
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
        visit current_path
        move_tile_between_sections @tiles1[@i1], @tiles2[@i2]

        expect_no_content move_modal_text

        @tiles2.insert @i2, @tiles1.delete_at(@i1)
        wait_for_ajax

        section_tile_headlines("##{@section1}").should == @tiles1.map(&:headline)
        section_tile_headlines("##{@section2}").should == @tiles2.map(&:headline)

        demo.reload.send(:"#{@section1}_tiles").should == @tiles1
        demo.reload.send(:"#{@section2}_tiles").should == @tiles2
      end

      it "should show modal if tile has completions. should not save on canseling", js: true do
        FactoryGirl.create :tile_completion, user: admin, tile: @tiles1[@i1]
        visit current_path
        move_tile_between_sections @tiles1[@i1], @tiles2[@i2]

        expect_content move_modal_text
        within move_modal_selector do
          click_link "Cancel"
        end

        wait_for_ajax
        # nothing changes
        section_tile_headlines("##{@section1}").should == @tiles1.map(&:headline)
        section_tile_headlines("##{@section2}").should == @tiles2.map(&:headline)

        demo.reload.send(:"#{@section1}_tiles").should == @tiles1
        demo.reload.send(:"#{@section2}_tiles").should == @tiles2
      end

      # should show modal if tile has completions. should save on confirming
      # i can't test this scenario. sadly
    end
  end

  context "Moves tiles on Inactive Tiles Page" do
    before(:each) { visit client_admin_inactive_tiles_path }
    it_should_behave_like "Moves tile in one section", "archive", 4, 0, 2
  end

  def move_modal_text
    "Are you sure you want to re-use this Tile? Users who completed it before won't see it again. If you want to re-use the content, please create a new Tile."
  end

  def move_modal_selector
    ".move-tile-confirm"
  end

end
