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
      create_tiles_for_sections section => tiles_num
      visit current_path #reload page
      tiles = demo.send(:"#{section}_tiles").to_a
      move_tile tiles[i1], tiles[i2]

      wait_for_ajax
      tile_id = tiles[i1].id
      tiles.insert i2, tiles.delete_at(i1)
      section_tile_headlines("##{section}").should == tiles.map(&:headline)
      demo.reload.send(:"#{section}_tiles").should == tiles

      expect_tile_status_updated_ping tile_id, admin
    end
  end

  shared_examples_for 'Moves tile between sections' do |section1, num1, i1, section2, num2, i2|
    scenario "Move tile #{num1 - i1} from #{section1} to tile #{num2 - i2} in #{section2}", js: true do
      create_tiles_for_sections section1 => num1, section2 => num2
      tiles1 = demo.send(:"#{section1}_tiles").to_a
      tiles2 = demo.send(:"#{section2}_tiles").to_a
      visit current_path
      move_tile_between_sections tiles1[i1], tiles2[i2]

      tile_id = tiles1[i1].id
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
      create_tiles_for_sections section1 => 9, section2 => 1
      i1 = section1 == "draft" ? 6 : 7
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
    it_should_behave_like "Moves tile between sections", "active",  6, 4, "archive", 2, 1
    it_should_behave_like "Moves tile between sections", "archive", 7, 3, "draft",   2, 1
    it_should_behave_like "Moves tile between sections", "archive", 7, 2, "active",  3, 2

    it_should_behave_like "Tile is loaded after drag and drop if needed", "archive", "active"
    it_should_behave_like "Tile is loaded after drag and drop if needed", "archive", "draft"
    it_should_behave_like "Tile is loaded after drag and drop if needed", "draft", "archive"
  end

  context "Moves tiles on Draft Tiles Page" do
    before(:each) { visit client_admin_draft_tiles_path }
    it_should_behave_like "Moves tile in one section", "draft", 3, 1, 0
  end

  context "Moves tiles on Inactive Tiles Page" do
    before(:each) { visit client_admin_inactive_tiles_path }
    it_should_behave_like "Moves tile in one section", "archive", 4, 0, 2
  end
end