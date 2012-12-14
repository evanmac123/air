require 'acceptance/acceptance_helper'

feature 'Admin conducts raffle' do
  def expect_winner_line(winner)
    expect_content "And the winner is...#{winner.name} (#{winner.email})"
  end

  def expect_no_winner_text
    expect_content "Nobody has any coins, so nobody is a winner. Or everybody is."
  end

  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_gold_coins)
  end

  context "when no segment is selected" do
    context "and no users have coins" do
      it "should say so", :js => true do
        5.times{ FactoryGirl.create(:user, demo: @demo)}
        @demo.users.map(&:gold_coins).sum.should be_zero

        signin_as_admin
        visit admin_demo_raffles_path(@demo)

        click_button "Pick a winner"

        expect_no_winner_text
      end
    end

    context "and some users have coins" do
      before(:each) do
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
    def segment_users
      select "Location", :from => "segment_column[0]"
      select "equals", :from => "segment_operator[0]"
      select "#{@locations[0].name} (#{@demo.name})", :from => "segment_value[0]"

      click_link "Add another"
      select "Shirt size", :from => "segment_column[1]"
      select "equals", :from => "segment_operator[1]"
      select "medium", :from => "segment_value[1]"

      click_button "Find segment"

      expect_content "5Users in segment"
    end

    before(:each) do
      @characteristic = FactoryGirl.create(:characteristic, :discrete, name: "Shirt size", allowed_values: %w(small medium large), demo: @demo)
      @locations = []
      3.times { @locations << FactoryGirl.create(:location, demo: @demo) }

      @expected_segment_users = []
      characteristic_hash = {@characteristic.id => 'medium'}
      5.times { @expected_segment_users << FactoryGirl.create(:user, :claimed, characteristics: characteristic_hash, location: @locations[0], demo: @demo) }

      4.times { FactoryGirl.create(:user, :claimed, characteristics: characteristic_hash, gold_coins: 15, demo: @demo) }
      3.times { FactoryGirl.create(:user, :claimed, location: @locations[0], gold_coins: 15, demo: @demo) }

      crank_dj_clear
    end

    context "and noUsers in that segment have coins" do
      it "should say so", :js => true do
        signin_as_admin
        visit admin_demo_raffles_path(@demo)
        segment_users

        click_button "Pick a winner"
        expect_no_winner_text
      end
    end

    context "and someUsers in that segment have coins" do
      before(:each) do
        @expected_segment_users.each_with_index do |user, i|
          user.update_attributes(gold_coins: i * 3)
        end

        crank_dj_clear
      end

      it "should select a user pseudorandomly proportional to how many coins they have", :js => true do
        Demo.any_instance.stubs(:rand).with(30).returns(0, 2, 3, 8, 9, 17, 18, 29)
        signin_as_admin
        visit admin_demo_raffles_path(@demo)
        segment_users

        1.upto(4) do |i|
          2.times do
            click_button "Pick a winner"
            expect_winner_line @expected_segment_users[i]
          end
        end
      end
    end
  end
end
