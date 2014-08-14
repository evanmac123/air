require 'spec_helper'

describe TileDigestDecorator do
  before(:each) do
    @tile = FactoryGirl.create :multiple_choice_tile
    crank_dj_clear
    @tile.reload
  end
  context "#email_img_url" do
    it "should return image url" do
      TileDigestDecorator.decorate(@tile).email_img_url.should match "email_digest/cov1_thumbnail.png"
    end
  end

  context "#email_link_options" do
    it "should return empty hash by default" do
      TileDigestDecorator.decorate(@tile).email_link_options.should == {}
    end

    it "should return target blank hash if decorator has is_preview context" do
      TileDigestDecorator.decorate(@tile, context: {is_preview: true}) \
        .email_link_options.should == {target: '_blank'} 
    end    
  end
end