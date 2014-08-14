require 'spec_helper'

describe TileBoardDigestDecorator do
  before(:each) do
  	@demo = FactoryGirl.create :demo
    @user = FactoryGirl.create :client_admin, demo: @demo
    @tile = FactoryGirl.create :multiple_choice_tile, demo: @demo
  end

  context "#email_site_link" do
    it "should return acts path for claimed user" do
      TileBoardDigestDecorator.decorate(@tile, context: {user: @user, demo: @demo}) \
      	.email_site_link.should match "acts"
    end
  end
end