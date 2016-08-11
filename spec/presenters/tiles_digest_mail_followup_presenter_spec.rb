require 'spec_helper'

describe TilesDigestMailFollowUpPresenter do
  describe "#site_link" do
    it "should escape invalid characters" do
      user = FactoryGirl.build(:user)
      presenter = TilesDigestMailFollowUpPresenter.new(user, user.demo, "custom from", "custom headline", "custom message", false, "Invalid Subject😎")

      expect(presenter.site_link.include?("Invalid Subject😎")).to eq(false)
      expect(presenter.site_link.include?("Invalid Subject")).to eq(true)
    end
  end
end
