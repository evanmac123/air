require "spec_helper"
include ClientAdmin::TilesHelper

describe SuggestedTileStatusMailer do
  let(:user) { FactoryBot.create(:claimed_user) }
  let(:demo) { FactoryBot.create :demo }
  let(:tile) { FactoryBot.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, original_creator: user }

  describe "#notify" do
    describe "when tile is accepted" do
      let(:mail) { SuggestedTileStatusMailer.notify_accepted(user: user, tile: tile) }

      it 'renders the subject' do
        expect(mail.subject).to eql(SuggestedTileStatusMailer::ACCEPTED_SUBJECT)
      end

      it 'renders the receiver email' do
        expect(mail.to).to eql([user.email])
      end
    end

    describe "when tile is posted" do
      let(:mail) { SuggestedTileStatusMailer.notify_posted(user: user, tile: tile) }

      it 'renders the subject' do
        expect(mail.subject).to eql(SuggestedTileStatusMailer::POSTED_SUBJECT)
      end

      it 'renders the receiver email' do
        expect(mail.to).to eql([user.email])
      end
    end
  end
end
