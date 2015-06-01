require 'spec_helper'

describe ActiveBoardCollector do

    before do
      @demo=FactoryGirl.create(:demo)
      @user=FactoryGirl.create(:user, demo: @demo)
      @tile1=FactoryGirl.create(:tile, demo: @demo)
      @tile2=FactoryGirl.create(:tile, demo: @demo)
			@viewing=FactoryGirl.create(:tile_viewing, tile: @tile1, user: @user)
			@completion=FactoryGirl.create(:tile_completion, tile: @tile2, user: @user)

			bm = BoardMembership.first
			bm.user = @user
			bm.demo = @demo
			bm.is_client_admin=true;
			bm.save
    end
  describe "#boards" do

		before do
			@beg_date=1.week.ago
			@end_date=Time.now
			@collector = ActiveBoardCollector.new(beg_date: @beg_date, end_date: @end_date) 
		end

		it "returns non-empty if tile viewing activity exists for date range" do
			@viewing.created_at = 2.days.ago
			@viewing.save
			expect(@collector.active_boards.any?).to be_true
		end 

		it "returns non-empty if tile completion activity exists for date range" do
			@completion.created_at = 2.days.ago
			expect(@collector.active_boards.any?).to be_true
		end

	  it "has only one active board" do
			@completion.created_at = 2.days.ago
			expect(@collector.active_boards.count).to eq(1) 
		end	

		it "correctly finds multiple active boards" do
      demo=FactoryGirl.create(:demo)
      user=FactoryGirl.create(:user, demo: demo)
      tile1=FactoryGirl.create(:tile, demo: demo)
      tile2=FactoryGirl.create(:tile, demo: demo)
			viewing=FactoryGirl.create(:tile_viewing, tile: tile1, user: user)
			completion=FactoryGirl.create(:tile_completion, tile: tile2, user: user)

			bm =demo.board_memberships.first
			bm.user = user
			bm.demo = demo
			bm.is_client_admin=true;
			bm.save

			viewing.created_at =  2.days.ago
			completion.created_at =  2.days.ago
			viewing.save
			completion.save
			@collector = ActiveBoardCollector.new(beg_date: @beg_date, end_date: @end_date) 
			expect(@collector.active_boards.count).to eq(2) 
		end 

	it "returns non-empty if tile completion activity exists for date range" do
			@completion.created_at = 2.days.ago
			expect(@collector.active_boards.any?).to be_true
		end 


  end

  describe "#admins" do
		before do
			@beg_date=1.week.ago
			@end_date=Time.now
		end

		it "returns one" do
			@viewing.created_at = 2.days.ago
			@viewing.save
      @collector = ActiveBoardCollector.new
			expect(@collector.board_admins(@demo).count).to eq(1) 
		end 

		it "returns muliple" do
			user2=FactoryGirl.create(:user,demo: nil)
      bm = BoardMembership.new
      bm.user = user2
      bm.demo = @demo
      bm.is_client_admin=true;
      bm.save
			@completion.created_at = 2.days.ago
			@viewing.save
      @collector = ActiveBoardCollector.new
			expect(@collector.board_admins(@demo).count).to eq(2) 
		end 
  end

	describe "#send_mail_notifications" do
		before do
      @viewing.created_at = 2.days.ago
      @viewing.save
		end
		it "sends notifications" do
      @collector = ActiveBoardCollector.new
			@collector.expects(:send_for_admin).once
			@collector.send_mail_notifications
		end
	end

end
