require 'acceptance/acceptance_helper'

feature 'Admin conducts raffle' do
  def expect_winner_line(winner)
    expect_content "And the winner is...#{winner.name} (#{winner.email})"
  end

  context "when no segment is selected" do
    context "and no users have coins" do
      it "should say so", :js => true do
        @demo = FactoryGirl.create(:demo, :with_gold_coins)
        5.times{ FactoryGirl.create(:user, demo: @demo)}
        @demo.users.map(&:gold_coins).sum.should be_zero

        signin_as_admin
        visit admin_demo_raffles_path(@demo)

        click_button "Pick a winner"

        expect_content "Nobody has any coins, so nobody is a winner. Or everybody is."
      end
    end

    context "and some users have coins" do
      before(:each) do
        @demo = FactoryGirl.create(:demo, :with_gold_coins)
        @users = []
        5.times{|i| @users << FactoryGirl.create(:user, demo: @demo, name: "Dude #{i}", gold_coins: i * 3)}
        @demo.users.map(&:gold_coins).sum.should == 30
      end

      context "and no maximum coin amount is specified" do
        it "should select a user pseudorandomly proportional to how many coins they have", :js => true do
          Demo.any_instance.stubs(:rand).with(30).returns(0, 2, 3, 8, 9, 17, 18, 29)
          signin_as_admin
          visit admin_demo_raffles_path(@demo)

          1.upto(4) do |i|
            2.times do
              click_button "Pick a winner"
              expect_winner_line @users[i]
            end
          end
        end
      end

      context "and a maximum count amount is specified" do
        it "should select a user pseudorandomly proportional to how many coins they have, subject to that maximum", :js => true do
          Demo.any_instance.stubs(:rand).with(18).returns(0, 2, 3, 7, 8, 12, 13, 17)
          signin_as_admin
          visit admin_demo_raffles_path(@demo)

          1.upto(4) do |i|
            2.times do
              fill_in "Only count coins up to:", :with => "5"
              click_button "Pick a winner"
              expect_winner_line @users[i]
            end
          end
        end
      end
    end
  end

  context "when a segment is selected" do
    context "and no users in that segment have coins" do
      it "should say so"
    end

    context "and some users in that segment have coins" do
      it "should select a user pseudorandomly proportional to how many coins they have"
    end
  end
end
