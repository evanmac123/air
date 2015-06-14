require "spec_helper"

include TileHelpers
include EmailHelper


describe SuggestedTileStatusMailer do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end


	describe "#accepted" do
		before do
			@demo, @user, @tile1 = setup_user_board
			@bm = setup_board_membership BoardMembership.first, @user, @demo
		end
		let(:mail) {SuggestedTileStatusMailer.accepted(@demo.id, @user, @tile1.id) }

		it 'renders the subject' do
			expect(mail.subject).to eql(SuggestedTileStatusMailer::ACCEPTED)
		end

		it 'renders the receiver email' do
			expect(mail.to).to eql([@user.email])
		end

		it 'has correct link' do
			expect(mail.body.encoded).to match(suggested_tiles_url)
		end

	end



	def setup_board_membership user, board, is_admin=true
		bm.demo = board 
		bm.user = user
		bm.is_client_admin=is_admin;
		bm.save
		bm
	end

	def setup_user_board user_is_client_admin=false
		demo=FactoryGirl.create(:demo)
		user=FactoryGirl.create(:user, demo: demo, is_client_admin: user_is_client_admin)
		tile1=create_demo_tile(demo)
		return demo, user, tile1, tile2
	end

	def create_demo_tile demo
		FactoryGirl.create(:tile, demo: demo)
	end

end

