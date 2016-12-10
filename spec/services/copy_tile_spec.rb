require 'spec_helper'

describe CopyTile do
  describe "#copy_tile" do
    before do
      @original_tile = FactoryGirl.create(:tile, points: 0)
      @copying_user = FactoryGirl.create(:client_admin)
      @copy_tile_service = CopyTile.new(@copying_user.demo, @copying_user)
    end

    it "should copy tile" do
      tile = @copy_tile_service.copy_tile(@original_tile)
      attr_list.each do |attr_name|
        expect(tile.send(attr_name)).to eq(@original_tile.send(attr_name))
      end
    end

    it "should set copied tile to first place in drafts" do
      demo = @copying_user.demo
      FactoryGirl.create_list(:tile, 3, demo: demo)
      tile = @copy_tile_service.copy_tile(@original_tile)
      expect(demo.draft_tiles.first.id).to eq(tile.id)
    end
  end
  #
  # => Helpers
  #
  def attr_list
    [
      "correct_answer_index",
      "headline",
      "link_address",
      "multiple_choice_answers",
      "points",
      "question",
      "supporting_content",
      "image_meta",
      "thumbnail_meta",
      "use_old_line_break_css"
    ]
  end
end
