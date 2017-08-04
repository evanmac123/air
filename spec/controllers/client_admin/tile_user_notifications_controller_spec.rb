require 'spec_helper'

describe ClientAdmin::TileUserNotificationsController do
  describe "#create" do
    let(:client_admin) { FactoryGirl.create(:client_admin) }
    let!(:tile) { FactoryGirl.create(:tile, multiple_choice_answers: ["a", "b", "c"], correct_answer_index: 0, demo: client_admin.demo) }

    before do
      Timecop.freeze(Time.local(1990))
      sign_in_as(client_admin)
    end

    after do
      Timecop.return
    end

    it "returns the new notification as json if valid" do
      post :create, tile_user_notification: { tile_id: tile.id, subject: "subject", message: "message", answer: "b", scope_cd: 1, send_at: Time.current + 1.day }

      expect(response.status).to eq(200)
      expect(response.content_type.json?).to eq(true)

      json_response = { "tile_user_notification"=>
        {
          "answer"=>"b",
           "created_at"=>"1990-01-01T03:00:00-05:00",
           "creator_id"=>1,
           "delayed_job_id"=>nil,
           "delivered_at"=>"1990-01-01T03:00:00-05:00",
           "id"=>1,
           "message"=>"message",
           "recipient_count"=>0,
           "scope_cd"=>1,
           "send_at"=>"1990-01-02T03:00:00-05:00",
           "subject"=>"subject",
           "tile_id"=>1,
           "updated_at"=>"1990-01-01T03:00:00-05:00"
        }
      }

      expect(JSON.parse(response.body)["tile_user_notification"].keys).to eq(json_response["tile_user_notification"].keys)
    end

    it "returns errors hash as json if notification could not be created" do
      post :create, tile_user_notification: { tile_id: tile.id, subject: nil, message: nil, answer: "b", scope_cd: 1, send_at: Time.current + 1.day }

      expect(response.status).to eq(422)
      expect(response.content_type.json?).to eq(true)

      json_response = {"errors"=>["Subject can't be blank", "Message can't be blank"]}

      expect(JSON.parse(response.body)).to eq(json_response)
    end

    it "returns access denied message if tryi to create a notification for a tile that is not in the current user's board" do
      post :create, tile_user_notification: { tile_id: 0 }

      expect(response.status).to eq(403)
      expect(response.content_type.json?).to eq(true)

      json_response = {"errors"=>"Access Denied"}

      expect(JSON.parse(response.body)).to eq(json_response)
    end
  end
end
