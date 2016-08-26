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




  context "Sending follow emails" do

    before  do 
      @demo = FactoryGirl.create(:demo)

      @muted = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)

      bm = @muted.board_memberships.first
      bm.followup_muted = true
      bm.save

      @user1 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user2 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user3 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user4 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user5 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)

      @user6 = FactoryGirl.create(:user, demo: @demo) #unclaimed


      @not_in_digest = FactoryGirl.create(:tile, :active, demo: @demo, )
      @tiles = FactoryGirl.create_list(:tile, 2, :active, demo: @demo, )

      FactoryGirl.create(:tile_completion, user: @user4, tile: @not_in_digest, created_at: 2.weeks.ago)

      FactoryGirl.create(:tile_completion, user: @user1, tile: @tiles[0], created_at: 2.weeks.ago)
      FactoryGirl.create(:tile_completion, user: @user2, tile: @tiles[0], created_at: 2.weeks.ago)
      FactoryGirl.create(:tile_completion, user: @user3, tile: @tiles[1], created_at: 2.weeks.ago)

      @fu = FollowUpDigestEmail.new(
        original_digest_headline: "headline", 
        send_on: 1.hour.from_now, 
        unclaimed_users_also_get_digest: false, 
        tile_ids: @tiles.map(&:id)
      )

      @fu.demo= @demo
      @fu.save
    end

    context "claimed" do
      before do
        @fu.user_ids_to_deliver_to = users_including_unclaimed(false)
        @fu.save
      end

      describe "#recipients" do
        it "list only claimed non muted users" do
          expect(@fu.recipients).to match_array [@user4.id, @user5.id]
          expect(@fu.user_ids_legacy).to match_array [@user4.id, @user5.id]
        end
      end
    end

    context "All users" do
      before do
        @fu.user_ids_to_deliver_to = users_including_unclaimed(true)
        @fu.unclaimed_users_also_get_digest = true
        @fu.save
      end

      describe "#recipients" do
        it "mails all non muted recipients" do
          expect(@fu.recipients).to match_array [@user4.id, @user5.id, @user6.id]
          expect(@fu.user_ids_legacy).to match_array [@user4.id, @user5.id, @user6.id]
        end 
      end

      describe "#trigger_deliveries" do 
        it "mails all recipients with no tile completions for the current digest tiles" do
          TilesDigestMailer.stubs(:delay).returns TilesDigestMailer
          TilesDigestMailer.expects(:notify_one).at_most(5)
          @fu.trigger_deliveries
        end
      end

    end
  end

  def users_including_unclaimed include_unclaimed
    #NOTE use this goofy method to avoid hardcoding the #user_ids_to_deliver_to
    #field on the model. Technically we could just hard code the values based on
    #the thing scenario we are testing claimed vs unclaimed and just user
    #User.all or User.claimed but this way we use the exact method as in the
    #current code implementation
    @demo.users_for_digest(include_unclaimed).pluck(:id)
  end

end
