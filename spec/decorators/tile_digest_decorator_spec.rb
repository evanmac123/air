require 'spec_helper'

describe TileDigestDecorator do
  before(:each) do
    @tile = FactoryGirl.create :multiple_choice_tile
    @tile.reload
  end
  context "#email_img_url" do
    it "should return image url" do
      expect(TileDigestDecorator.decorate(@tile).email_img_url).to match "email_digest/cov1_thumbnail.jpg"
    end
  end

  context "#email_link_options" do
    it "should return empty hash by default" do
      expect(TileDigestDecorator.decorate(@tile).email_link_options).to eq({})
    end

    it "should return target blank hash if decorator has is_preview context" do
      expect(TileDigestDecorator.decorate(@tile, context: {is_preview: true}) \
        .email_link_options).to eq({target: '_blank'})
    end
  end
end
