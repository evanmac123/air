require 'rails_helper'

describe ClientAdmin::ReportsHelper do
  before do
    @helper = Object.new.extend(ClientAdmin::ReportsHelper)
  end

  describe "#redirect_path_for_tile_token_auth" do
    it "returns tiles_path if tile is present" do
      helper.stubs(:set_tile_id_for_open_graph)

      helper.expects(:get_tile_from_params).returns(Tile.new)
      helper.expects(:params).returns({ tile_id: 1 })

      expect(helper.redirect_path_for_tile_token_auth).to eq("/tiles?tile_id=1")
    end

    it "returns activity_path if tile is not present" do
      expect(helper.redirect_path_for_tile_token_auth).to eq("/activity")
    end

    it "asks to set_tile_id_for_open_graph" do
      helper.expects(:set_tile_id_for_open_graph)

      helper.redirect_path_for_tile_token_auth
    end
  end

  describe "#get_tile_from_params" do
    it "returns requested tile if it exists and current_user is present" do
      user = FactoryGirl.create(:user)
      board = user.demo
      tile = FactoryGirl.create(:tile, demo: board)

      helper.expects(:current_user).returns(user)
      helper.expects(:params).returns({ tile_id: tile.id }).twice
      helper.expects(:current_board).returns(board)

      expect(helper.get_tile_from_params).to eq(tile)
    end

    it "returns nil if current_user is not present" do
      helper.expects(:current_user).returns(nil)

      expect(helper.get_tile_from_params).to eq(nil)
    end

    it "returns nil if params[:tile_id] is not present" do
      helper.expects(:current_user).returns(true)
      helper.expects(:params).returns({})

      expect(helper.get_tile_from_params).to eq(nil)
    end
  end

  describe "#set_tile_id_for_open_graph" do
    it "adds tile id to session" do
      helper.expects(:params).returns({ tile_id: 1 })

      helper.set_tile_id_for_open_graph

      expect(helper.session[:open_graph_tile_id]).to eq(1)
    end
  end
end
