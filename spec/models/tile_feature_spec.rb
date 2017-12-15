require 'spec_helper'

describe TileFeature do
  it { is_expected.to validate_presence_of :name}
  it { is_expected.to validate_uniqueness_of :name}
  it { is_expected.to validate_presence_of :rank}

  let(:tile_feature) {FactoryGirl.create(:tile_feature, active: true)}

  it "assigns redis values given hash of parameters" do
    FactoryGirl.create_list(:tile, 6, is_public: true)
    tile_feature.dispatch_redis_updates(redis_params)

    expect(tile_feature.custom_icon_url).to eq(redis_params["custom_icon_url"])
    expect(tile_feature.text_color).to eq(redis_params["text_color"])
    expect(tile_feature.header_copy).to eq(redis_params["header_copy"])
    expect(tile_feature.background_color).to eq(redis_params["background_color"])
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
      tile_id = FactoryGirl.create(:tile, is_public: true).id
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
      FactoryGirl.create_list(:tile, 5, is_public: true)
      tile_id_1 = Tile.first.id
      tile_id_3 = Tile.all[3].id
      tile_id_2 = Tile.last.id

      tile_feature.dispatch_redis_updates({ tile_ids: "#{tile_id_2},#{tile_id_3},#{tile_id_1}" })
      feature_tiles = tile_feature.get_tiles(Tile.all)

      expect(feature_tiles.map(&:id).join(",")).to eq("#{tile_id_2},#{tile_id_3},#{tile_id_1}")
    end
  end

  context "tile collections in explore do not include featured tiles" do
    it "excludes featured tiles in the Tile.explore_without_featured_tiles query" do
      org = FactoryGirl.create(:organization, name: "Airbo")
      FactoryGirl.create_list(:tile, 10, organization: org, is_public: true)

      expect(Tile.explore_without_featured_tiles.count).to eq(10)

      tile_feature = FactoryGirl.create(:tile_feature, active: true)

      tile_ids = Tile.limit(5).pluck(:id).join(",")
      tile_feature.dispatch_redis_updates({ tile_ids: tile_ids })

      expect(Tile.explore_without_featured_tiles.count).to eq(5)
    end
  end
end
