require 'acceptance/acceptance_helper'

feature 'Previews a public tile' do
  context "when the user clicks through a tag in the preview page navbar" do
    it "goes follows correct path" do
      @tile = FactoryGirl.create(:tile, :public)
      @first_tag = @tile.tile_tags.first
      @first_tag.should be_present

      visit explore_tile_preview_path(@tile.id, as: a_client_admin)
      click_link @first_tag.title

      should_be_on tile_tag_show_explore_path
      page.should have_content "Explore: #{@first_tag.topic.name}: #{@first_tag.title}"
    end
  end
end
