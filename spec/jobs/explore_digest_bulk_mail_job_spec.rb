require 'rails_helper'

RSpec.describe ExploreDigestBulkMailJob, type: :job do
  describe "#perform" do
    before do
      FactoryBot.create_list(:tile, 6, is_public: true)

      @explore_digest = ExploreDigest.create
      @params = explore_digest_params
      @explore_digest.post_to_redis(@params["defaults"], @params["features"])
    end

    it "should send a message to all client admin" do
      FactoryBot.create_list(:user, 3, is_client_admin: true)
      FactoryBot.create_list(:user, 2, is_client_admin: false)

      ExploreDigestBulkMailJob.perform_now(@explore_digest)

      expect(ActionMailer::Base.deliveries.size).to eq(3)
    end
  end

  def explore_digest_params
    {
      "defaults"=> {
        "subject"=>"Subject",
        "header"=>"Header",
        "subheader"=>"Subheader",
        "color"=>""
      },
      "features"=> {
        "1"=> {
          "headline"=>"Test Headline 1",
          "headline_icon_url"=>"test_url_1",
          "feature_message"=>"Test Message 1",
          "tile_ids"=>Tile.all[0..1].map(&:id).join(",")
        },
        "2"=> {
         "headline"=>"Test Headline 2",
         "headline_icon_url"=>"test_url_2",
         "feature_message"=>"Test Message 2",
         "tile_ids"=>Tile.all[2..3].map(&:id).join(",")
        },
        "3"=> {
         "headline"=>"Test Headline 3",
         "headline_icon_url"=>"test_url_3",
         "feature_message"=>"Test Message 3",
         "tile_ids"=>Tile.all[4..5].map(&:id).join(",")
        }
      }
    }
  end
end
