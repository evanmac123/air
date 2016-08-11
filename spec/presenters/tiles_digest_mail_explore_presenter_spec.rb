require 'spec_helper'

describe TilesDigestMailExplorePresenter do
  describe "#site_link" do
    it "should escape invalid characters" do
      presenter = TilesDigestMailExplorePresenter.new("custom_from", "custom message", "email heading", "explore token", "Invalid Subject😎\255")

      expect(presenter.site_link.include?("Invalid Subject😎\255")).to eq(false)
      expect(presenter.site_link.include?("Invalid Subject")).to eq(true)
    end
  end
end
