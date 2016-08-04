require 'spec_helper'

describe ClientAdmin::TilesController do
  describe "POST create" do
    it "should ping Mixpanel when a tile is created" do
      subject.stubs(:ping)
      subject.stubs(:schedule_tile_creation_ping)
      demo = FactoryGirl.create(:demo)
      client_admin = FactoryGirl.create(:client_admin, demo: demo)

      sign_in_as(client_admin)

      xhr :post, :create, tile_builder_form: tile_builder_form

      expect(response.status).to eq(200)
      expect(subject).to have_received(:schedule_tile_creation_ping)
    end
  end

  describe "GET new" do
    it "sends new tile ping" do
      subject.stubs(:ping)
      client_admin = FactoryGirl.create(:client_admin)
      sign_in_as(client_admin)

      get :new

      expect(subject).to have_received(:ping).with('Tiles Page', {action: 'Clicked Add New Tile'}, subject.current_user)
    end
  end

  def tile_builder_form
    {"status"=>"draft",
     "remote_media_type"=>"image/jpeg",
     "image_from_library"=>"",
     "remote_media_url"=>"https://hengage-tiles-development.s3.amazonaws.com/uploads/bd567e01a6077ceb72bed5fc0cdfa31a/avatar.jpg",
     "image_credit"=>"",
     "embed_video"=>"",
     "headline"=>"TEST",
     "supporting_content"=>"<p>TEST</p>",
     "question_type"=>"Action",
     "question_subtype"=>"read_tile",
     "question"=>"Points for reading tile",
     "answers"=>["I read it"],
     "points"=>"10"}
  end
end
