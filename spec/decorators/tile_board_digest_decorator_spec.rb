require 'spec_helper'

describe TileBoardDigestDecorator do
  before(:each) do
  	@demo = FactoryBot.create :demo
    @user = FactoryBot.create :client_admin, demo: @demo
    @tile = FactoryBot.create :multiple_choice_tile, demo: @demo
  end

  context "#email_site_link" do
    it "should return acts path for claimed user" do
      expect(TileBoardDigestDecorator.decorate(@tile, context: {user: @user, demo: @demo}) \
      	.email_site_link).to match "acts"
    end
  end
end