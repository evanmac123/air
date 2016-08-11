require 'spec_helper'

describe TilesDigestMailDigestPresenter do
  describe "#site_link" do
    it "should escape invalid characters" do
      user = FactoryGirl.build(:user)
      presenter = TilesDigestMailDigestPresenter.new(user, user.demo, "custom from", "custom headline", "custom message", false, "Invalid Subject😎\255")

      expect(presenter.site_link.include?("Invalid Subject😎\255")).to eq(false)
      expect(presenter.site_link.include?("Invalid Subject")).to eq(true)
    end
  end
end
