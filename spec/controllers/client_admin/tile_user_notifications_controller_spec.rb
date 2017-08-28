require 'spec_helper'

describe ClientAdmin::TileUserNotificationsController do
  let(:client_admin) { FactoryGirl.create(:client_admin) }
  let!(:tile) { FactoryGirl.create(:multiple_choice_tile, multiple_choice_answers: ["a", "b", "c"], correct_answer_index: 0, demo: client_admin.demo) }

  before do
    Timecop.freeze(Time.utc(1990))
    sign_in_as(client_admin)
  end

  after do
    Timecop.return
  end

  describe "#create" do
    describe "when it is not a test notification" do
      describe "when valid and not a test" do
        it "asks a TileUserNotification to deliver" do
          TileUserNotification.any_instance.expects(:deliver_notifications).once

          post :create, tile_user_notification: { tile_id: tile.id, subject: "subject", message: "message", answer_idx: 0, scope_cd: 1 }
        end

        it "returns the new notification" do
          post :create, tile_user_notification: { tile_id: tile.id, subject: "subject", message: "message", answer_idx: 0, scope_cd: 1 }

          expect(response.status).to eq(200)
          expect(response.content_type.json?).to eq(true)

          mock_json_response = {
            "tile_id"=>tile.id,
            "creator_id"=>client_admin.id,
            "subject"=>"subject",
            "message"=>"message",
            "scope_cd"=>1,
            "delivered_at"=>"1989-12-31T19:00:00-05:00",
            "recipient_count"=>0,
            "send_at"=>nil,
            "delayed_job_id"=>nil,
            "created_at"=>"1989-12-31T19:00:00-05:00",
            "updated_at"=>"1989-12-31T19:00:00-05:00",
            "answer_idx"=>0,
            "answer"=>"a",
            "scope"=>"did not answer"
          }

          response_without_id = JSON.parse(response.body)["tile_user_notification"].reject { |k,v| k =="id" }

          expect(response_without_id).to eq(mock_json_response)
        end

        it "returns errors hash as json if notification could not be created" do
          post :create, tile_user_notification: { tile_id: tile.id, subject: nil, message: nil, answer_idx: 0, scope_cd: 1, send_at: Time.current + 1.day }

          expect(response.status).to eq(422)
          expect(response.content_type.json?).to eq(true)

          json_response = {"errors"=>["Subject can't be blank", "Message can't be blank"]}

          expect(JSON.parse(response.body)).to eq(json_response)
        end
      end
      end

    describe "when it is a test notification" do
      it "returns an unsaved instance of a notification as json if valid" do
        TileUserNotification.any_instance.expects(:deliver_test_notification).with(user: client_admin).once

        post :create, tile_user_notification: { tile_id: tile.id, subject: "subject", message: "message", answer_idx: 0, scope_cd: 1 }, test_notification: true

        expect(response.status).to eq(200)
        expect(response.content_type.json?).to eq(true)

        mock_json_response = { "tile_user_notification"=>
          {
            "id"=> nil,
            "tile_id"=>tile.id,
            "creator_id"=>client_admin.id,
            "subject"=>"subject",
            "message"=>"message",
            "scope_cd"=>1,
            "delivered_at"=>nil,
            "recipient_count"=>nil,
            "send_at"=>nil,
            "delayed_job_id"=>nil,
            "created_at"=>nil,
            "updated_at"=>nil,
            "answer_idx"=>0,
            "answer"=>"a",
            "scope"=>"did not answer"
          }
        }

        expect(JSON.parse(response.body)).to eq(mock_json_response)
        expect(response.status).to eq(200)
      end

      it "returns errors hash as json if notification could not be created" do
        post :create, tile_user_notification: { tile_id: tile.id, subject: nil, message: nil, answer_idx: 0, scope_cd: 1 }, test_notification: true

        expect(response.status).to eq(422)
        expect(response.content_type.json?).to eq(true)

        json_response = {"errors"=>["Subject can't be blank", "Message can't be blank"]}

        expect(JSON.parse(response.body)).to eq(json_response)
      end
    end

    it "returns access denied message if try to create a notification for a tile that is not in the current user's board" do
      post :create, tile_user_notification: { tile_id: 0 }

      expect(response.status).to eq(403)
      expect(response.content_type.json?).to eq(true)

      json_response = {"errors"=>"Access Denied"}

      expect(JSON.parse(response.body)).to eq(json_response)
    end
  end

  describe "#new" do
    it "returns a new instance of TileUserNotification with a recipient_count when valid" do
      get :new, tile_user_notification: { tile_id: tile.id, scope_cd: 1, answer_idx: 0 }

      expect(response.status).to eq(200)
      expect(response.content_type.json?).to eq(true)

      mock_json_response = { "tile_user_notification"=>
        {
          "answer_idx"=>0,
          "created_at"=>nil,
          "creator_id"=>client_admin.id,
          "delayed_job_id"=>nil,
          "delivered_at"=>nil,
          "id"=>nil,
          "message"=>nil,
          "recipient_count"=>0,
          "scope_cd"=>1,
          "send_at"=>nil,
          "subject"=>nil,
          "tile_id"=>tile.id,
          "updated_at"=>nil
          }
        }

        expect(JSON.parse(response.body)).to eq(mock_json_response)
    end

    it "returns access denied message if try to create a notification for a tile that is not in the current user's board" do
      get :new, tile_user_notification: { tile_id: 0 }

      expect(response.status).to eq(403)
      expect(response.content_type.json?).to eq(true)

      json_response = {"errors"=>"Access Denied"}

      expect(JSON.parse(response.body)).to eq(json_response)
    end
  end
end
