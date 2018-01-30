require "spec_helper"

describe Tile::Placeholder do
  describe "#is_placeholder?" do
    it "returns true" do
      expect(Tile::Placeholder.new.is_placeholder?).to eq(true)
    end
  end
end
