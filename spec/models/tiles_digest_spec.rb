require 'rails_helper'

RSpec.describe TilesDigest, :type => :model do
  describe "#self.build_and_create" do

    def digest_params(demo, current_user)
      {
        demo: FactoryGirl.create,
        unclaimed_users_also_get_digest: unclaimed_users_also_get_digest,
        custom_headline: custom_headline,
        custom_message: custom_message,
        custom_subject: custom_subject,
        alt_custom_subject: alt_custom_subject,
        follow_up_day: follow_up_day,
        current_user: current_user
      }
    end

    it "persists digest with necessary attrs and relationships" do
      client_admin = FactoryGirl.create(:client_admin)
      demo = client_admin.demo
      _tiles = FactoryGirl.create_list(:tile, 5, demo: demo)
      
    end
  end
end
