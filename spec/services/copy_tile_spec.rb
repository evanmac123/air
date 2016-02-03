require 'spec_helper'

describe CopyTile do
  describe "#copy_tile" do
    before do
      @original_tile = FactoryGirl.create :multiple_choice_tile, :active, headline: "Copy me!"
      @demo = FactoryGirl.create :demo
      FactoryGirl.create_list :multiple_choice_tile, 5, :draft
      @copying_user = FactoryGirl.create :client_admin

      @ct = CopyTile.new(@demo, @copying_user)
    end

    it "should copy tile" do
      tile = @ct.copy_tile(@original_tile, false)

      attr_list.each do |attr_name|
        expect(tile.send(attr_name)).to eq(@original_tile.send(attr_name))
      end
    end

    it "should set copied tile to first place in drafts" do
      tile = @ct.copy_tile(@original_tile, false)
      @demo.reload
      @demo.draft_tiles.first.id == tile.id
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
