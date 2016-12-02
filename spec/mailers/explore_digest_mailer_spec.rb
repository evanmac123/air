require "spec_helper"

include TileHelpers
include EmailHelper

describe ExploreDigestMailer do
  before(:each) do
    FactoryGirl.create_list(:tile, 6, is_copyable: true, is_public: true)

    @explore_digest = ExploreDigest.create
    @params = explore_digest_params
    @explore_digest.post_to_redis(@params["defaults"], @params["features"])
  end

  describe "#notify_one" do
    it "should send a message with correct data" do
      user = FactoryGirl.create(:user, is_client_admin: true)

      ExploreDigestMailer.notify_one(@explore_digest, user).deliver

      ActionMailer::Base.deliveries.should have(1).email

      ActionMailer::Base.deliveries.each do |mail|
        mail.to_s.should contain("Subject")
        mail.to_s.should contain("Header")
        mail.to_s.should contain("Subheader")
        mail.to_s.should contain("Test Headline 1")
        mail.to_s.should contain("Test Headline 2")
        mail.to_s.should contain("Test Headline 3")
      end
    end
  end

  describe "#notify_all" do
    it "should send a message to all client admin" do
      FactoryGirl.create_list(:user, 3, is_client_admin: true)
      FactoryGirl.create_list(:user, 2, is_client_admin: false)

      ExploreDigestMailer.notify_all(@explore_digest)

      ActionMailer::Base.deliveries.should have(3).emails
    end
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
