require 'spec_helper'

describe ClientAdmin::TileCompletionsController do
  it "should not permit a client admin to look at tiles in a board they're not in, but rather 404" do
    forbidden_tile = FactoryGirl.create(:tile)
    client_admin = FactoryGirl.create(:client_admin)

    expect(forbidden_tile.demo_id).not_to eq(client_admin.demo_id)

    sign_in_as(client_admin)
    get :index, tile_id: forbidden_tile.id

    expect(response).to be_not_found
  end
end
