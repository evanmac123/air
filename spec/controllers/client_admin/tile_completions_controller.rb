require 'spec_helper'

describe ClientAdmin::TileCompletionsController do
  it "should not permit a client admin to look at tiles in a board they're not in, but rather 404" do
    forbidden_tile = FactoryGirl.create(:tile)
    client_admin = FactoryGirl.create(:client_admin)

    forbidden_tile.demo_id.should_not == client_admin.demo_id

    sign_in_as(client_admin)
    get :index, tile_id: forbidden_tile.id

    response.should be_not_found
  end
end
