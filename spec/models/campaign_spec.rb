require 'spec_helper'

describe Campaign do
  it { is_expected.to belong_to :demo }
  it { is_expected.to have_many :tiles }
  it { is_expected.to validate_uniqueness_of :name }
  it { is_expected.to validate_presence_of :name }

  describe "self.exclude" do
    it "excludes campaigns given an array of ids" do
      campaigns = FactoryBot.create_list(:campaign, 5)
      campaign_ids = campaigns.map(&:id)
      excluded_campaigns = campaign_ids[0..1]

      expect(Campaign.exclude(excluded_campaigns).pluck(:id).sort).to eq(campaigns[2..-1].map(&:id).sort)
    end
  end

  describe "#update_slug" do
    it "triggers on save" do
      campaign = FactoryBot.build(:campaign)

      campaign.expects(:update_slug)

      campaign.save
    end

    it "updates the slug" do
      campaign = FactoryBot.build(:campaign, name: "Campaign Name")
      expect(campaign.slug).to eq(nil)

      campaign.save
      expect(campaign.slug).to eq("campaign-name")
    end
  end

  describe "#active_tiles" do
    it "returns tiles that are active, archived and public" do
      demo = FactoryBot.create(:demo)
      active_tile = FactoryBot.create(:tile, demo: demo, is_public: true, status: Tile::ACTIVE)
      _inactive_tile = FactoryBot.create(:tile, demo: demo, is_public: true, status: Tile::DRAFT)

      campaign = FactoryBot.create(:campaign, demo: demo)

      expect(campaign.active_tiles.first).to eq(active_tile)
      expect(campaign.active_tiles.count).to eq(1)
    end
  end

  describe "#tile_count" do
    it "only counts active tiles" do
      demo = FactoryBot.create(:demo)
      _active_tiles = FactoryBot.create_list(:tile, 3, demo: demo, is_public: true, status: Tile::ACTIVE)
      _inactive_tiles = FactoryBot.create(:tile, demo: demo, is_public: true, status: Tile::DRAFT)

      campaign = FactoryBot.create(:campaign, demo: demo)

      expect(campaign.tile_count).to eq(3)
    end
  end

  describe "#to_param" do
    it "hyphenates id and slug to optimize seo while still relying on id for look ups" do
      campaign = FactoryBot.create(:campaign)

      expect(campaign.to_param).to eq("#{campaign.id}-#{campaign.slug}")
    end

    it "only returns the id when the result of to_param calls to_i" do
      campaign = FactoryBot.create(:campaign)

      expect(campaign.to_param.to_i).to eq(campaign.id)
    end
  end

  describe "#related_channels" do
    it "returns a collection of channels that match the campain's channel_list" do
      channels = FactoryBot.create_list(:channel, 3)
      _excluded_channel = FactoryBot.create(:channel, name: "Excluded Channel")
      campaign = FactoryBot.create(:campaign)

      channels.map(&:name).each { |c|
        campaign.channel_list.add(c)
      }

      expect(campaign.related_channels.map(&:id).sort).to eq(channels.map(&:id).sort)
    end
  end

  describe "#formatted_instructions" do
    it "splits instructions on \n" do
      campaign = FactoryBot.build(:campaign, instructions: "line 1\nline 2\nline 3")

      expect(campaign.formatted_instructions).to eq(["line 1", "line 2", "line 3"])
    end
  end

  describe "#formatted_sources" do
    it "splits sources on commas, strips whitespace and groups name with url" do
      campaign = FactoryBot.build(:campaign, sources: "place1, url1, place2, url2")

      expect(campaign.formatted_sources).to eq([["place1", "url1"], ["place2", "url2"]])
    end
  end

  describe "#search_data" do
    it "indexes the correct data" do
      campaign = FactoryBot.create(:campaign)

      required_fields = ["name", "description", :channel_list, :tile_headlines, :tile_content]

      require_fields_present = (campaign.search_data.keys + required_fields).uniq.length == campaign.search_data.keys.length

      expect(require_fields_present).to eq(true)
    end

    it "indexes channel_lists correctly" do
      campaign = FactoryBot.create(:campaign)
      campaign.channel_list.add("channel")

      expect(campaign.search_data[:channel_list]).to eq(["channel"])
    end

    it "indexes tile_headlines correctly" do
      demo = FactoryBot.create(:demo)
      tile = FactoryBot.create(:tile, demo: demo)
      campaign = FactoryBot.create(:campaign, demo: demo)

      expect(campaign.search_data[:tile_headlines]).to eq([tile.headline])
    end

    it "indexes tile_content correctly" do
      demo = FactoryBot.create(:demo)
      tile = FactoryBot.create(:tile, demo: demo)
      campaign = FactoryBot.create(:campaign, demo: demo)

      expect(campaign.search_data[:tile_content]).to eq([tile.supporting_content])
    end
  end
end
