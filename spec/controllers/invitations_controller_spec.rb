require 'spec_helper'

describe InvitationsController do
  describe "GET show" do
    let(:inviter) { FactoryGirl.create(:client_admin) }
    let(:user) { FactoryGirl.create(:user) }

    it "should require_login if user is not found" do
      subject.stubs(:require_login)

      get :show, {
        id: 0,
        demo_id: inviter.demo.id,
        referrer_id: inviter.id
      }

      expect(subject).to have_received(:require_login).once
    end

    describe "pings" do
      it "should send tile email tracking ping when there is a user and the params specify email type and a tile email id" do
        TileEmailTracker.stubs(:dispatch)

        get :show, {
          id: user.invitation_code,
          demo_id: inviter.demo.id,
          referrer_id: inviter.id,
          email_type: "tile_digest",
          tiles_digest_id: "1",
          subject_line: "NEW TILES"
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
        TileEmailTracker.stubs(:dispatch)

        get :show, {
          id: user.invitation_code,
          demo_id: inviter.demo.id,
          referrer_id: inviter.id
        }

        expect(TileEmailTracker).to have_received(:dispatch).never
      end
    end
  end
end
