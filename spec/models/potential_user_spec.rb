require 'spec_helper'

describe PotentialUser do
  let(:demo) { FactoryGirl.create :demo }
  let(:user) { FactoryGirl.create(:potential_user, email: "bill@jo.com", demo: demo) }

  it { should belong_to(:demo) }
  it { should belong_to(:game_referrer) }
  it { should have_many(:peer_invitations) }

  it { should validate_uniqueness_of(:invitation_code) }

  describe '#convert_to_full_user!' do
    context "happy path" do 
      before(:each) do
        user.convert_to_full_user! "Bill Jo"
        @new_user = User.last
      end

      it "should copy name" do
        @new_user.name.should == "Bill Jo"
      end

      it "should copy email" do
        @new_user.email.should == user.email
      end

      it "should generate some cancel_account_token" do
        @new_user.cancel_account_token.should be_present
      end

      it "should add new user to demo" do
        @new_user.demo.should == user.demo
      end
    end

    context "unhappy path" do
      it "should not save user without name" do
        user.convert_to_full_user! nil
        User.count.should == 0
      end
    end
  end

  describe "#is_invited_by" do
    context "good path" do
      let(:invitation) { stub('invitation') }

      before do
        @inviter = FactoryGirl.create :user, demo: demo

        Mailer.stubs(:invitation => invitation)
        invitation.stubs(:deliver)
        user.is_invited_by @inviter
        crank_dj_clear
      end

      it "sends invitation to user" do
        Mailer.should     have_received(:invitation)
        invitation.should have_received(:deliver)
      end

      it "should record a PeerInvitation" do
        PeerInvitation.count.should == 1

        invitation = PeerInvitation.first
        invitation.inviter.should == @inviter
        invitation.invitee.should == user
        invitation.demo.should == @inviter.demo
      end
    end

    context "user already has #{PeerInvitation::CUTOFF} invitations" do
      before(:each) do
        PeerInvitation::CUTOFF.times {FactoryGirl.create(:peer_invitation, invitee: user, demo: user.demo)}
        user.reload.peer_invitations.count.should == PeerInvitation::CUTOFF

        other_user = FactoryGirl.create(:user)
        user.is_invited_by(other_user)
        crank_dj_clear
      end

      it "should not send another invitation email" do
        ActionMailer::Base.deliveries.should be_empty
      end

      it "should not record another PeerInvitation" do
        user.reload.peer_invitations.count.should == PeerInvitation::CUTOFF
      end
    end
  end
end
