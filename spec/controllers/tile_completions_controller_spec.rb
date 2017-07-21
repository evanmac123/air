require "spec_helper"

describe TileCompletionsController do
  it "should not let you complete a tile for a board you're not in" do
    subject.stubs(:ping)

    tile = FactoryGirl.create(:tile)
    user = FactoryGirl.create(:user)

    expect(user).not_to be_in_board(tile.demo_id)
    expect(TileCompletion.count).to eq(0)

    sign_in_as user
    post :create, tile_id: tile.id

    expect(response.request.flash[:failure]).to eq(I18n.t('flashes.failure_cannot_complete_tile_in_different_board'))
    expect(TileCompletion.count).to eq(0)
  end

  context "in board" do

    let(:demo) {FactoryGirl.create :demo}
    let(:tile) {FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)}
    let(:user) {FactoryGirl.create :user, demo: demo}

    it "should create act if tile is anonymous" do

      Tile.any_instance..stubs(:is_anonymous?).returns(true)
      sign_in_as user
      expect(Act.count).to eq(0)
      post :create, tile_id: tile.id

    end

    it "should create act if tile is not anonymous" do

      Tile.any_instance.stubs(:is_anonymous?).returns(false)
      sign_in_as user
      post :create, tile_id: tile.id

      expect(Act.count).to eq(1)
    end
  end
end
