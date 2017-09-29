require 'spec_helper'

describe ActsController do
  it 'should reject attempts to sign in with an invalid security token (as found in tile links in digest email)' do
    user = FactoryGirl.create :user
    get :index, tile_token: '123456789', user_id: user.id
    expect(response).to redirect_to sign_in_url
  end

  describe "pings" do
    let(:user) { FactoryGirl.create :user }
    it "should send tile email tracking ping when there is a user and the params specify email type and a tile email id" do
      TileEmailTracker.stubs(:delay).returns(TileEmailTracker)
      TileEmailTracker.stubs(:dispatch)

      token = EmailLink.generate_token(user)

      sign_in_as(user)

      get :index, {
        email_type: "tile_digest",
        tiles_digest_id: "1",
        subject_line: "NEW TILES",
        tile_token: token,
        user_id: user.id
      }

      expect(TileEmailTracker).to have_received(:dispatch).with({
        user: user,
        email_type: "tile_digest",
        subject_line: "NEW TILES",
        tile_email_id: "1",
        from_sms: false
      })
    end

    it "should NOT send tile email tracking ping when the params do not specify email type and a tile email id" do
      TileEmailTracker.stubs(:delay).returns(TileEmailTracker)
      TileEmailTracker.stubs(:dispatch)

      sign_in_as(user)

      get :index

      expect(TileEmailTracker).to have_received(:dispatch).never
    end
  end
end
