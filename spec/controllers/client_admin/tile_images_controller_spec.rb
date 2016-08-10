require 'spec_helper'

describe ClientAdmin::TileImagesController do
  describe "GET index" do
    it "should return correct tiles" do
      subject.stubs(:ping)
      demo = FactoryGirl.create(:demo)
      client_admin = FactoryGirl.create(:client_admin, demo: demo)
      tile_images = FactoryGirl.create_list :tile_image, 55
      TileImage.update_all(image_processing: false, thumbnail_processing: false)

      sign_in_as(client_admin)
      get :index, page: 1
      assigns(:tile_images).count.should == 18
      assigns(:tile_images).map(&:id).should == TileImage.order{ created_at.desc }[35..52].map(&:id)
    end
  end
end
