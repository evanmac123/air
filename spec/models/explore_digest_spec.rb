require 'spec_helper'

describe ExploreDigest do
  it "posts to redis and validates copyable tiles" do
    explore_digest = ExploreDigest.create
    params = explore_digest_params

    explore_digest.post_to_redis(params["defaults"], params["features"])
    expect(explore_digest.defaults(:subject)).to eq(params["defaults"]["subject"])
    expect(explore_digest.defaults(:header)).to eq(params["defaults"]["header"])
    expect(explore_digest.defaults(:subheader)).to eq(params["defaults"]["subheader"])

    expect(explore_digest.features(1, :headline)).to eq(params["features"]["1"]["headline"])
    expect(explore_digest.features(1, :headline_icon_url)).to eq(params["features"]["1"]["headline_icon_url"])
    expect(explore_digest.features(1, :feature_message)).to eq(params["features"]["1"]["feature_message"])
    expect(explore_digest.features(1, :tile_ids)).to eq("")

    expect(explore_digest.features(3, :headline)).to eq(params["features"]["3"]["headline"])
    expect(explore_digest.features(3, :headline_icon_url)).to eq(params["features"]["3"]["headline_icon_url"])
    expect(explore_digest.features(3, :feature_message)).to eq(params["features"]["3"]["feature_message"])
    expect(explore_digest.features(3, :tile_ids)).to eq("")
  end

  it "validates copyable tiles appropriately" do
    FactoryGirl.create_list(:tile, 3, is_copyable: true, is_public: true)
    FactoryGirl.create_list(:tile, 2, is_copyable: false, is_public: true)
    FactoryGirl.create_list(:tile, 2, is_copyable: true, is_public: false)
    FactoryGirl.create_list(:tile, 2, is_copyable: false, is_public: false)

    explore_digest = ExploreDigest.create
    params = { "features" => { "1" => { "tile_ids"=> Tile.pluck(:id).join(", ") } } }

    explore_digest.post_to_redis(params["defaults"], params["features"])

    eq(params["features"]["1"]["feature_message"])
    expect(explore_digest.features(1, :tile_ids)).to eq(Tile.copyable.pluck(:id).sort.join(","))
  end

  it "can tell you how many features it has" do
    explore_digest = ExploreDigest.create
    params = explore_digest_params

    explore_digest.post_to_redis(params["defaults"], params["features"])

    expect(explore_digest.feature_count).to eq(3)
  end

  it "retrieves tiles in correct order" do
    FactoryGirl.create_list(:tile, 3, is_copyable: true, is_public: true)
    FactoryGirl.create_list(:tile, 2, is_copyable: false, is_public: true)
    FactoryGirl.create_list(:tile, 2, is_copyable: true, is_public: false)
    FactoryGirl.create_list(:tile, 2, is_copyable: false, is_public: false)

    explore_digest = ExploreDigest.create
    tile_ids = Tile.copyable.pluck(:id).shuffle.join(", ")
    params = { "features" => { "1" => { "tile_ids"=> tile_ids } } }

    explore_digest.post_to_redis(params["defaults"], params["features"])
    sorted_tiles = explore_digest.get_tiles(1)

    expect(sorted_tiles.map(&:id)).to eq(tile_ids.split(", ").map(&:to_i))
  end

  def explore_digest_params
    {
      "defaults"=> {
        "subject"=>"Subject",
        "header"=>"Header",
        "subheader"=>"Subheader"
      },
      "features"=> {
        "1"=> {
          "headline"=>"Test Headline 1",
          "headline_icon_url"=>"test_url_1",
          "feature_message"=>"Test Message 1",
          "tile_ids"=>"1, 2, 3, 4"
        },
        "2"=> {
         "headline"=>"Test Headline 2",
         "headline_icon_url"=>"test_url_2",
         "feature_message"=>"Test Message 2",
         "tile_ids"=>"5, 6, 7, 8"
        },
        "3"=> {
         "headline"=>"Test Headline 3",
         "headline_icon_url"=>"test_url_3",
         "feature_message"=>"Test Message 3",
         "tile_ids"=>"9, 10, 11, 12"
        }
      }
    }
  end
end
