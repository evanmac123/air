require 'spec_helper'

describe FullSizeTilePresenter do
  describe "#supporting_content" do
    let(:user) {FactoryBot.build_stubbed(:user)}

    def ie8
      'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.2; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0)'
    end

    it "should turn all-whitespace lines into HTML-safed non-breaking spaces" do
      tile = FactoryBot.build_stubbed(:tile, supporting_content: "Line 1\n\nLine 2")
      presenter = FullSizeTilePresenter.new(tile, user, false, [], Browser.new('chrome'))
      expect(presenter.supporting_content).to eq("<p>Line 1</p><p>&nbsp;</p><p>Line 2</p>")
    end

    it "should retain multiple spaces by turning them into non-breaking spaces" do
      tile = FactoryBot.build_stubbed(:tile, supporting_content: "   Here  There   Everywhere")
      presenter = FullSizeTilePresenter.new(tile, user, false, [], Browser.new('chrome'))
      expect(presenter.supporting_content).to eq("<p>   Here  There   Everywhere</p>")
    end

    it "should escape tags in the supporting content" do
      tile = FactoryBot.build_stubbed(:tile, supporting_content: "<script>alert('Bad evil!')</script>")
      presenter = FullSizeTilePresenter.new(tile, user, false, [], Browser.new('chrome'))
      expect(presenter.supporting_content).to eq("<p>&lt;script&gt;alert(&#39;Bad evil!&#39;)&lt;/script&gt;</p>")
    end
  end
end
