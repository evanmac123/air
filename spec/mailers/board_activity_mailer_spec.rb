require "spec_helper"

include TileHelpers
include EmailHelper


describe BoardActivityMailer do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end


	describe "#notify" do
		before do
			@demo, @user, @tile1, @tile2 = setup_user_board
			@viewing = setup_viewing @user, @tile1
			@completion = setup_completion(@user, @tile2)
			@bm = setup_board_membership BoardMembership.first, @user, @demo
		end
		let(:mail) {BoardActivityMailer.notify(@demo.id, @user, [@tile1.id, @tile2.id], 1.week.ago, Time.now ) }

		it 'renders the subject' do
			expect(mail.subject).to eql(BoardActivityMailer::ACTIVITY_DIGEST_HEADING)
		end

		it 'renders the receiver email' do
			expect(mail.to).to eql([@user.email])
		end

		it 'renders the sender email' do
			expect(mail.from).to eql(["play@ourairbo.com"])
		end

		it 'has correct CTA text' do
			expect(mail.body.encoded).to match("See Your Tiles")
		end

		it 'does not mention not having to log in ' do
			expect(mail.body.encoded).not_to match("You won't have to log in.")
		end
	end


	def setup_viewing user, tile
		FactoryGirl.create(:tile_viewing, tile: tile, user: user, created_at: 1.day.ago)
	end

	def setup_completion user, tile
		FactoryGirl.create(:tile_completion, tile: tile, user: user, created_at: 1.day.ago)
	end

	def setup_board_membership bm, user, board, is_admin=true
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
		tile2=create_demo_tile(demo)
		return demo, user, tile1, tile2
	end

	def create_demo_tile demo
		FactoryGirl.create(:tile, demo: demo)
	end

	def create_date_range_collector
		ActiveBoardCollector.new(beg_date: @beg_date, end_date: @end_date) 
	end

end

