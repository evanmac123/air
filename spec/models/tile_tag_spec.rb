require 'spec_helper'

describe TileTag do
  it { should have_many(:tiles) }

  describe '.alphabetical' do
    it 'should be alphabetical, but use the ASCII ordering so most punctuation comes first' do
      %w(@foo bar !baz).each do |title|
        FactoryGirl.create(:tile_tag, title: title)
      end

      TileTag.alphabetical.pluck(:title).should == %w(!baz @foo bar)
    end
  end

  describe ".rearrange" do
    it "should put tag to last position by name" do
      ["Wellness", "Compliance", "Other", "Recruitment"].each{|name| TileTag.create(title: name)}
      TileTag.rearrange("Other").map(&:title).should == ["Wellness", "Compliance", "Recruitment", "Other"]
    end

    it "should leave tags unchangable if tag with the name is not present" do
      ["Wellness", "Compliance", "Recruitment"].each{|name| TileTag.create(title: name)}
      TileTag.rearrange("Other").map(&:title).should == ["Wellness", "Compliance", "Recruitment"]
    end
  end
end
