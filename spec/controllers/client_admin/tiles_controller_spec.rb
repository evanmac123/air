require 'spec_helper'

describe ClientAdmin::TilesController do
  describe "POST create" do
    it "should ping Mixpanel when a tile is created" do
      subject.stubs(:ping)
      subject.stubs(:schedule_tile_creation_ping)
      Tile.any_instance.stubs(:process_image)
      demo = FactoryGirl.create(:demo)
      client_admin = FactoryGirl.create(:client_admin, demo: demo)

      sign_in_as(client_admin)

      xhr :post, :create, tile: tile

      expect(response.status).to eq(200)
      expect(subject).to have_received(:schedule_tile_creation_ping)
    end
  end

  def tile
    {"status"=>"draft",
     "remote_media_type"=>"image/jpeg",
     "image_from_library"=>"",
     "remote_media_url"=>"http://some/remote/s3/image",
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
