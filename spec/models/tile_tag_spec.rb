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
end
