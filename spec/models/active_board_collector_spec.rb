require 'spec_helper'

describe ActiveBoardCollector do


	before do
		@beg_date=1.week.ago
		@end_date=Time.now
		@demo, @user, tile1, tile2 = setup_user_board
		@viewing = setup_viewing @user, tile1
		@completion = setup_completion(@user, tile2)
		@bm = setup_board_membership BoardMembership.first, @user, @demo
	end

	describe "#boards" do
		before do
			@collector = create_date_range_collector
		end

		it "returns non-empty if tile viewing activity exists for date range" do
			expect(@collector.active_boards.any?).to be_true
		end 

		it "has only one active board" do
			expect(@collector.active_boards.count).to eq(1) 
		end	

		it "returns non-empty if tile viewing activity exists for date range" do
			expect(@collector.active_boards.any?).to be_true
		end 

		it "returns empty if no tile activity exists for date range" do
			@completion.update_attribute(:created_at, 2.weeks.ago)
			@viewing.update_attribute(:created_at, 2.weeks.ago)
			@collector = create_date_range_collector
			expect(@collector.active_boards.blank?).to be_true
		end

		it "correctly finds multiple active boards" do
			demo, user, tile1, tile2 = setup_user_board
			viewing = setup_viewing user, tile1
			setup_board_membership demo.board_memberships.first, user, demo
			@collector = create_date_range_collector
			expect(@collector.active_boards.count).to eq(2) 
		end 

	end

	describe "#board_admins" do

		let(:user){FactoryGirl.create(:user,demo: nil)}

		it "returns one" do
			@collector = ActiveBoardCollector.new
			expect(@collector.board_admins(@demo).count).to eq(1) 
		end 

		it "returns muliple" do
			setup_board_membership BoardMembership.new, user, @demo
			@collector = ActiveBoardCollector.new
			expect(@collector.board_admins(@demo).count).to eq(2) 
		end

		it "returns non empty if user is a client admin and the user is on current board" do
			@user.update_attribute(:is_client_admin, true)
			@bm.update_attribute(:is_client_admin, false)
			@collector = ActiveBoardCollector.new

			expect(@collector.board_admins(@demo).count).to eq(1)
		end

		it "returns empty if user is not client admin on isn't a client admin on the board" do
			@user.update_attribute(:is_client_admin, true)
			@bm.update_attribute(:is_client_admin, false)
			@bm.update_attribute(:is_current, false)
			@collector = ActiveBoardCollector.new
			expect(@collector.board_admins(@demo).count).to eq(0)
		end

		it "returns empty if user is has weekly report disabled for board" do
			@bm.update_attribute(:send_weekly_activity_report, false)
			@collector = ActiveBoardCollector.new
			expect(@collector.board_admins(@demo).count).to eq(0)
		end

		it "returns empty if user is not client admin on isn't a client admin on the board" do
			@bm.update_attribute(:is_client_admin, false)
			@collector = ActiveBoardCollector.new
			expect(@collector.board_admins(@demo).count).to eq(0)
		end

	end

	describe "#send_mail_notifications" do
		it "sends notifications" do
			@collector = create_date_range_collector 
			@collector.expects(:send_for_admin).once
			@collector.send_mail_notifications
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
