require 'spec_helper'

describe CopyTile do
  describe "#copy_tile" do
    before do
      @original_tile = FactoryGirl.create :multiple_choice_tile, :active, headline: "Copy me!"
      @ct = CopyTile.new(@original_tile.demo, @original_tile.creator)
    end

    it "should copy tile" do
      tile = @ct.copy_tile(@original_tile, false)

      attr_list.each do |attr_name|
        expect(tile.send(attr_name)).to eq(@original_tile.send(attr_name))
      end
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
      "type",
      "image_meta",
      "thumbnail_meta"
    ]
  end
end
