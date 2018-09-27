require 'spec_helper'

describe ActsController do
  it 'should reject attempts to sign in with an invalid security token (as found in tile links in digest email)' do
    user = FactoryBot.create :user
    get :index, tile_token: '123456789', user_id: user.id
    expect(response).to redirect_to sign_in_path
  end

  describe "pings" do
    let(:user) { FactoryBot.create :user }
    it "should send tile email tracking ping when there is a user and the params specify email type and a tile email id" do
      TileEmailTrackerJob.expects(:perform_later).with({
        user: user,
        email_type: "tile_digest",
        subject_line: "NEW TILES",
        tile_email_id: "1",
        from_sms: false
      })

      token = EmailLink.generate_token(user)

      sign_in_as(user)

      get :index, {
        email_type: "tile_digest",
        tiles_digest_id: "1",
        subject_line: "NEW TILES",
        tile_token: token,
        user_id: user.id
      }
    end

    it "should NOT send tile email tracking ping when the params do not specify email type and a tile email id" do
      TileEmailTrackerJob.expects(:perform_later).never

      sign_in_as(user)

      get :index
    end
  end
end
