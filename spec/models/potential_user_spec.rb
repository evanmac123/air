require 'spec_helper'

describe PotentialUser do
  let(:demo) { FactoryBot.create :demo }
  let(:user) { FactoryBot.create(:potential_user, email: "bill@jo.com", demo: demo, primary_user: nil) }

  it { is_expected.to belong_to(:demo) }
  it { is_expected.to belong_to(:game_referrer) }
  it { is_expected.to belong_to(:primary_user) }
  it { is_expected.to have_many(:peer_invitations) }

  it { is_expected.to validate_uniqueness_of(:invitation_code) }

  context "primary user is destroyed" do
    it "should also be destroyed" do
      user = FactoryBot.create(:user)
      FactoryBot.create(:potential_user, primary_user_id: user.id)
      FactoryBot.create(:potential_user, primary_user_id: user.id)

      expect(PotentialUser.count).to eq(2)

      user.destroy

      expect(PotentialUser.count).to eq(0)
    end
  end

  describe '#convert_to_full_user!' do
    context "happy path" do
      before(:each) do
        user.convert_to_full_user! "Bill Jo"
        @new_user = User.last
      end

      it "should copy name" do
        expect(@new_user.name).to eq("Bill Jo")
      end

      it "should copy email" do
        expect(@new_user.email).to eq(user.email)
      end

      it "should generate some cancel_account_token" do
        expect(@new_user.cancel_account_token).to be_present
      end

      it "should add new user to demo" do
        expect(@new_user.demo).to eq(user.demo)
      end
    end

    context "unhappy path" do
      it "should not save user without name" do
        user.convert_to_full_user! nil
        expect(User.count).to eq(0)
      end
    end
  end

  describe "#is_invited_by" do
    context "good path" do
      let(:invitation) { stub('invitation') }

      before do
        @inviter = FactoryBot.create :user, demo: demo

        Mailer.stubs(:invitation => invitation)
        invitation.stubs(:deliver_later)
        user.is_invited_by @inviter

      end

      it "sends invitation to user" do
        expect(Mailer).to     have_received(:invitation)
        expect(invitation).to have_received(:deliver_later)
      end

      it "should record a PeerInvitation" do
        expect(PeerInvitation.count).to eq(1)

        invitation = PeerInvitation.first
        expect(invitation.inviter).to eq(@inviter)
        expect(invitation.invitee).to eq(user)
        expect(invitation.demo).to eq(@inviter.demo)
      end
    end

    context "user already has #{PeerInvitation::CUTOFF} invitations" do
      before(:each) do
        PeerInvitation::CUTOFF.times {FactoryBot.create(:peer_invitation, invitee: user, demo: user.demo)}
        expect(user.reload.peer_invitations.count).to eq(PeerInvitation::CUTOFF)

        other_user = FactoryBot.create(:user)
        user.is_invited_by(other_user)

      end

      it "should not send another invitation email" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "should not record another PeerInvitation" do
        expect(user.reload.peer_invitations.count).to eq(PeerInvitation::CUTOFF)
      end
    end
  end
end
