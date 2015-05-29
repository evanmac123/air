require 'spec_helper'

describe ActiveBoardCollector do

  describe "#boards" do

    before do
      @user=FactoryGirl.create(:user)
      @demo=@user.demo
      @tile1=FactoryGirl.create(:tile, demo: @demo)
      @tile2=FactoryGirl.create(:tile, demo: @demo)
      @viewing=FactoryGirl.create(:tile_viewing, tile: 
                                  @tile1, user: @user)
      @completion=FactoryGirl.create(:tile_completion, 
                                     tile: @tile2, user: @user)
      @beg_date=1.week.ago
      @end_date=Time.now

      bm = BoardMembership.new
      bm.user = @demo.users.first
      bm.demo = @demo
      bm.is_client_admin=true;
      bm.save
      @collector = ActiveBoardCollector.new(beg_date: @beg_date, 
                                            end_date: @end_date) 
    end

    it "returns non-empty if tile viewing activity exists for date range" do
      @viewing.created_at = 2.days.ago
      @viewing.save
      expect(@collector.boards.any?).to be_true
    end 

    it "returns non-empty if tile completion activity exists for date range" do
      @completion.created_at = 2.days.ago
      expect(@collector.boards.any?).to be_true
    end 

    it "returns empty if no completion nor viewing activity for date range" do
      @viewing.created_at =  2.weeks.ago
      @completion.created_at =  2.weeks.ago
      @viewing.save
      @completion.save
      expect(@collector.boards.empty?).to be_true
    end 

  end

end
