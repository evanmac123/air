require "spec_helper"

include TileHelpers
include EmailHelper


describe SuggestedTileStatusMailer do
	let(:user){FactoryGirl.create(:user)}
	let(:demo) { FactoryGirl.create :demo }
	let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, original_creator: user }

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end


	describe "#accepted" do

		let(:mail) {SuggestedTileStatusMailer.accepted(demo.id, user.id, tile.id) }

		it 'renders the subject' do
			expect(mail.subject).to eql(SuggestedTileStatusMailer::ACCEPTED)
		end

		it 'renders the receiver email' do
			expect(mail.to).to eql([user.email])
		end

		it 'has correct link' do
			expect(mail.body.encoded).to match(suggested_tiles_url)
		end

	end


	describe "#posted" do

		let(:mail) {SuggestedTileStatusMailer.posted(demo.id, user.id, tile.id) }

		it 'renders the subject' do
			expect(mail.subject).to eql(SuggestedTileStatusMailer::POSTED)
		end

		it 'renders the receiver email' do
			expect(mail.to).to eql([user.email])
		end

		it 'has correct link' do
			expect(mail.body.encoded).to match(suggested_tiles_url)
		end

	end

	describe "#archived" do

		let(:mail) {SuggestedTileStatusMailer.posted(demo.id, user.id, tile.id) }

		it 'renders the subject' do
			expect(mail.subject).to eql(SuggestedTileStatusMailer::POSTED)
		end

		it 'renders the receiver email' do
			expect(mail.to).to eql([user.email])
		end

		it 'has correct link' do
			expect(mail.body.encoded).to match(suggested_tiles_url)
		end

	end


end

