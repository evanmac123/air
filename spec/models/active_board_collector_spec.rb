require 'spec_helper'

describe ActiveBoardCollector do

	describe "#collect" do

    before do
		@viewing){FactoryGirl.create(:tile_viewing)}
		@completion){FactoryGirl.create(:tile_completion)}
		@tile){viewing.tile}
		@demo){tile.demo}
		@beg_date){1.week.ago}
		@end_date){Time.now}
			@collector = ActiveBoardCollector.new(beg_date: beg_date, end_date: end_date) 
		end

		it "returns true if tile viewing activity exists for date range" do
			viewing.update_attribute(:created_at,  2.days.ago)
			expect(@collector.collect.any?).to be_true
		end 

		it "returns true if tile completion activity exists for date range" do
			completion.update_attribute(:created_at,  2.days.ago)
			expect(@collector.collect.any?).to be_true
		end 

		it "returns false if neither tile completion nor viewing activity  exists for date range" do
			viewing.update_attribute(:created_at,  2.weeks.ago)
			completion.update_attribute(:created_at,  2.weeks.ago)
			expect(@collector.collect.any?).to be_false
		end 

	end

end
