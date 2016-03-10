require 'spec_helper'

describe Concerns::TileImageable do
  context "#full_size_image_height" do
    it "should return default size if height or width is nil but image is not processed" do
      t = FactoryGirl.create(:multiple_choice_tile, image: File.open(Rails.root.join "spec/support/fixtures/tiles/cov'1.jpg"))
      # well, yeah, that's made-up scenario
      t.image_processing = false

      expect(t.image_processing?).to eql(false)
      expect(t.image.height).to eql(nil)
      expect(t.image.width).to eql(nil)
      # so default
      expect(t.full_size_image_height).to eql((484 * 600.0 / 666).to_i)
    end
  end
end