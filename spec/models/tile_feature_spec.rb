require 'spec_helper'

describe TileFeature do
  it { should validate_presence_of :name}
  it { should validate_uniqueness_of :name}
  it { should validate_presence_of :rank}
  it { should validate_uniqueness_of :rank}

  let(:tile_feature) { FactoryGirl.create(:tile_feature, active: true) }

  it "assigns redis values given hash of parameters" do
    FactoryGirl.create_list(:tile, 6, is_copyable: true, is_public: true)
    tile_feature.dispatch_redis_updates(redis_params)

    expect(tile_feature.custom_icon_url).to eq(redis_params["custom_icon_url"])
    expect(tile_feature.text_color).to eq(redis_params["text_color"])
    expect(tile_feature.header_copy).to eq(redis_params["header_copy"])
    expect(tile_feature.background_color).to eq(redis_params["background_color"])
    expect(tile_feature.tile_ids).to eq(redis_params["tile_ids"].split(","))
  end

  def redis_params
    {"custom_icon_url"=>"url", "text_color"=>"#000000", "header_copy"=>"Some Copy", "background_color"=>"#ffffff", "tile_ids"=>"1,2,3,4,5"}
  end

  context "tile id formatting" do
    it "handles empty tile id inputs" do
      tile_feature.dispatch_redis_updates({ tile_ids: "" })

      expect(tile_feature.tile_ids).to eq([])
    end

    it "handles nil tile id inputs" do
      tile_feature.dispatch_redis_updates({ tile_ids: nil })

      expect(tile_feature.tile_ids).to eq(nil)
    end

    it "removes non integers" do
      tile_id = FactoryGirl.create(:tile, is_copyable: true, is_public: true).id
      tile_feature.dispatch_redis_updates({ tile_ids: "word, ##32, #{tile_id}" })

      expect(tile_feature.tile_ids).to eq(["#{tile_id}"])
    end
  end

  context "active scope" do
    it "selects only active tile features" do
      FactoryGirl.create(:tile_feature, active: nil)
      FactoryGirl.create(:tile_feature, active: true)
      FactoryGirl.create(:tile_feature, active: false)
      FactoryGirl.create(:tile_feature, active: false)

      expect(TileFeature.active.length).to eq(1)
    end
  end

  context "order scope" do
    it "selects only active tile features" do
      last = FactoryGirl.create(:tile_feature, active: true, rank: 10)
      first = FactoryGirl.create(:tile_feature, active: true, rank: 1)
      FactoryGirl.create(:tile_feature, active: true, rank: 5)

      tile_features = TileFeature.ordered

      expect(tile_features.first).to eq(first)
      expect(tile_features.last).to eq(last)
      expect(tile_features.count).to eq(3)
    end
  end

  context "tile retrieval" do
    it "gets tiles in the correct order" do
      FactoryGirl.create_list(:tile, 5, is_copyable: true, is_public: true)
      tile_id_1 = Tile.first.id
      tile_id_3 = Tile.all[3].id
      tile_id_2 = Tile.last.id

      tile_feature.dispatch_redis_updates({ tile_ids: "#{tile_id_2},#{tile_id_3},#{tile_id_1}" })
      feature_tiles = tile_feature.get_tiles(Tile.scoped)

      expect(feature_tiles.map(&:id).join(",")).to eq("#{tile_id_2},#{tile_id_3},#{tile_id_1}")
    end
  end

  context "tile collections in explore do not include featured tiles" do
    it "excludes featured tiles in the Tile.verified_explore query" do
      org = FactoryGirl.create(:organization, name: "Airbo")
      FactoryGirl.create_list(:tile, 10, organization: org, is_copyable: true, is_public: true)

      expect(Tile.verified_explore.count).to eq(10)

      tile_feature = FactoryGirl.create(:tile_feature, active: true)

      tile_ids = Tile.limit(5).pluck(:id).join(",")
      tile_feature.dispatch_redis_updates({ tile_ids: tile_ids })

      expect(Tile.verified_explore.count).to eq(5)
    end
  end
end
