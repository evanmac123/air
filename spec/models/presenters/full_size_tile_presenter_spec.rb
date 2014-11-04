require 'spec_helper'

describe FullSizeTilePresenter do
  describe "#supporting_content" do
    it "should turn all-whitespace lines into HTML-safed non-breaking spaces" do
      tile = FactoryGirl.build_stubbed(:tile, supporting_content: "Line 1\n\nLine 2")
      presenter = FullSizeTilePresenter.new(tile)
      presenter.supporting_content.should == "<p>Line&nbsp;1</p><p>&nbsp;</p><p>Line&nbsp;2</p>"
    end

    it "should retain multiple spaces by turning them into non-breaking spaces" do
      tile = FactoryGirl.build_stubbed(:tile, supporting_content: "   Here  There   Everywhere")
      presenter = FullSizeTilePresenter.new(tile)
      presenter.supporting_content.should == "<p>&nbsp;&nbsp;&nbsp;Here&nbsp;&nbsp;There&nbsp;&nbsp;&nbsp;Everywhere</p>"
    end

    it "should escape tags in the supporting content" do
      tile = FactoryGirl.build_stubbed(:tile, supporting_content: "<script>alert('Bad evil!')</script>")
      presenter = FullSizeTilePresenter.new(tile)
      presenter.supporting_content.should == "<p>&lt;script&gt;alert(&#x27;Bad&nbsp;evil!&#x27;)&lt;/script&gt;</p>"
    end
  end
end
