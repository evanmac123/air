require 'spec_helper'

describe ActiveTileCollector do

  describe "#collect" do

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

      @collector = ActiveTileCollector.new(@demo, @beg_date, @end_date) 
    end

    it "returns true if tile viewing activity exists for date range" do
      @viewing.update_attribute(:created_at,  2.days.ago)
      expect(@collector.collect.any?).to be_true
    end 

    it "returns true if tile completion activity exists for date range" do
      @completion.update_attribute(:created_at,  2.days.ago)
      expect(@collector.collect.any?).to be_true
    end 

    it "is false if there is no completion or viewing activity for date range" do
      @viewing.update_attribute(:created_at,  2.weeks.ago)
      @completion.update_attribute(:created_at,  2.weeks.ago)
      expect(@collector.collect.any?).to be_false
    end 

  end

end
