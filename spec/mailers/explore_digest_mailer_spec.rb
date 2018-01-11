require "spec_helper"

include TileHelpers
include EmailHelper

describe ExploreDigestMailer do
  before(:each) do
    FactoryBot.create_list(:tile, 6, is_public: true)

    @explore_digest = ExploreDigest.create
    @params = explore_digest_params
    @explore_digest.post_to_redis(@params["defaults"], @params["features"])
  end

  describe "#notify_one" do
    it "should send a message with correct data" do
      user = FactoryBot.create(:user, is_client_admin: true)

      ExploreDigestMailer.notify_one(@explore_digest, user).deliver

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      ActionMailer::Base.deliveries.each do |mail|
        expect(mail.to_s).to contain("Subject")
        expect(mail.to_s).to contain("Header")
        expect(mail.to_s).to contain("Subheader")
        expect(mail.to_s).to contain("Test Headline 1")
        expect(mail.to_s).to contain("Test Headline 2")
        expect(mail.to_s).to contain("Test Headline 3")
      end
    end

    it "adds custom X-SMTPAPI header" do
      user = FactoryBot.create(:user, is_client_admin: true)
      mail = ExploreDigestMailer.notify_one(@explore_digest, user)

      x_smtpapi_header = JSON.parse(mail.header["X-SMTPAPI"].value)
      custom_unique_args = user.data_for_mixpanel.merge({
        subject: mail.subject,
        digest_id: @explore_digest.id,
        email_type: "explore_digest"
      }).to_json

      expect(x_smtpapi_header["category"]).to eq("explore_digest")
      expect(x_smtpapi_header["unique_args"]).to eq(JSON.parse(custom_unique_args))
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
