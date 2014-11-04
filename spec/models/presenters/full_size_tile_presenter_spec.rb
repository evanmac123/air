require 'spec_helper'

describe FullSizeTilePresenter do
  describe "#supporting_content" do
    it "should turn all-whitespace lines into HTML-safed non-breaking spaces" do
      tile = FactoryGirl.build_stubbed(:tile, supporting_content: "Line 1\n\nLine 2")
      presenter = FullSizeTilePresenter.new(tile)
      presenter.supporting_content.should == "<p>Line 1</p><p>&nbsp;</p><p>Line 2</p>"
    end
  end
end
