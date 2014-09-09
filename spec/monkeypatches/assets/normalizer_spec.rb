require "spec_helper"

describe Assets::Normalizer do
  it "normalizes tile filename" do
    tile = FactoryGirl.create(:multiple_choice_tile, image: File.open(Rails.root.join "spec/support/fixtures/tiles/cov'1.jpg"))
    tile.image_file_name.should == "cov-1.jpg"
  end
end