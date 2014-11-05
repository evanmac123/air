require 'spec_helper'

describe FullSizeTilePresenter do
  describe "#supporting_content" do
    let(:user) {FactoryGirl.build_stubbed(:user)}

    it "should turn all-whitespace lines into HTML-safed non-breaking spaces" do
      tile = FactoryGirl.build_stubbed(:tile, supporting_content: "Line 1\n\nLine 2")
      presenter = FullSizeTilePresenter.new(tile, user, false)
      presenter.supporting_content.should == "<p>Line 1</p><p>&nbsp;</p><p>Line 2</p>"
    end

    it "should retain multiple spaces by turning them into non-breaking spaces" do
      tile = FactoryGirl.build_stubbed(:tile, supporting_content: "   Here  There   Everywhere")
      presenter = FullSizeTilePresenter.new(tile, user, false)
      presenter.supporting_content.should == "<p>   Here  There   Everywhere</p>"
    end

    it "should escape tags in the supporting content" do
      tile = FactoryGirl.build_stubbed(:tile, supporting_content: "<script>alert('Bad evil!')</script>")
      presenter = FullSizeTilePresenter.new(tile, user, false)
      presenter.supporting_content.should == "<p>&lt;script&gt;alert(&#x27;Bad evil!&#x27;)&lt;/script&gt;</p>"
    end
  end
end
