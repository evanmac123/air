require 'spec_helper'

describe FollowUpDigestEmail do
  describe '#follow_up_days' do
    it "returns 0 when the specified day is 'Never'" do
      FollowUpDigestEmail.follow_up_days('Never').should == 0
    end

    it "returns the number of days the specified day occurs after the current day" do
      days = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

      Timecop.freeze(Time.new(2013, 11, 3))  # Sunday
      results = [7, 1, 2, 3, 4, 5, 6]
      days.each_with_index { |day, i| FollowUpDigestEmail.follow_up_days(day).should == results[i] }

      Timecop.freeze(Time.new(2013, 11, 6))  # Wednesday
      results = [4, 5, 6, 7, 1, 2, 3]
      days.each_with_index { |day, i| FollowUpDigestEmail.follow_up_days(day).should == results[i] }

      Timecop.freeze(Time.new(2013, 11, 9))  # Saturday
      results = [1, 2, 3, 4, 5, 6, 7]
      days.each_with_index { |day, i| FollowUpDigestEmail.follow_up_days(day).should == results[i] }

      Timecop.return
    end
  end


  describe "#trigger_deliveries" do
    before do
      @demo = FactoryGirl.create(:demo)

      @user1 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user2 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user3 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user4 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user5 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user6 = FactoryGirl.create(:user, demo: @demo)
      @tiles = FactoryGirl.create_list(:tile, 2, :active, demo: @demo, )

      FactoryGirl.create(:tile_completion, user: @user1, tile: @tiles[0], created_at: 2.weeks.ago)
      FactoryGirl.create(:tile_completion, user: @user2, tile: @tiles[0], created_at: 2.weeks.ago)
      FactoryGirl.create(:tile_completion, user: @user3, tile: @tiles[1], created_at: 2.weeks.ago)
    end 
    context "send to all " do
      before do
        user_ids = User.all.map(&:id)
        @fu = FollowUpDigestEmail.new(original_digest_headline: "headline", send_on: 1.hour.from_now, unclaimed_users_also_get_digest: true, user_ids_to_deliver_to: user_ids, tile_ids: @tiles.map(&:id))
        @fu.demo= @demo
        @fu.save
      end

      it "is valid" do
        expect{@fu.valid?}.to be_true
      end

      it "mails all recipients" do
        TilesDigestMailer.stubs(:delay).returns TilesDigestMailer
        TilesDigestMailer.expects(:notify_one).at_most(5)
        @fu.trigger_deliveries
      end 

      it "mails all recipients" do
        expect(@fu.recipients).to eq [@user4.id, @user5.id, @user6.id]
      end 
    end
    context "send to activated only " do
      before do
        user_ids = User.claimed.map(&:id)
        @fu = FollowUpDigestEmail.new(original_digest_headline: "headline", send_on: 1.hour.from_now, unclaimed_users_also_get_digest: false, user_ids_to_deliver_to: user_ids, tile_ids: @tiles.map(&:id))
        @fu.demo= @demo
        @fu.save
      end

      it "mails all activated recipients" do
        expect(@fu.recipients).to eq [@user4.id, @user5.id]
      end 
    end
  end
end
