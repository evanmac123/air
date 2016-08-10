require 'acceptance/acceptance_helper'

feature 'Admin conducts raffle' do

  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_tickets)
  end

  context "when no segment is selected" do
    context "and no users have tickets" do
      before do
        5.times{ FactoryGirl.create(:user, demo: @demo)}
        @admin = an_admin
        @demo.users.map(&:tickets).sum.should be_zero
      end

      it "should say so", :js => true do
        visit admin_demo_raffles_path(@demo, as: @admin)

        click_button "Pick a winner"

        expect_no_winner_text
      end
    end

    context "and some users have tickets" do
      before(:each) do
        @users = []
        5.times{|i| @users << FactoryGirl.create(:user, demo: @demo, name: "Dude #{i}", tickets: i * 3)}
        @demo.users.map(&:tickets).sum.should == 30
      end

      context "and no maximum ticket amount is specified" do
        it "should select a user pseudorandomly proportional to how many tickets they have", :js => true do
          Demo.any_instance.stubs(:rand).with(30).returns(0, 2, 3, 8, 9, 17, 18, 29)
          visit admin_demo_raffles_path(@demo, as: an_admin)

          1.upto(4) do |i|
            2.times do
              click_button "Pick a winner"
              expect_winner_line @users[i]
            end
          end
        end
      end

      context "and a maximum count amount is specified" do
        it "should select a user pseudorandomly proportional to how many tickets they have, subject to that maximum", :js => true do
          Demo.any_instance.stubs(:rand).with(18).returns(0, 2, 3, 7, 8, 12, 13, 17)
          visit admin_demo_raffles_path(@demo, as: an_admin)

          1.upto(4) do |i|
            2.times do
              fill_in "Only count tickets up to:", :with => "5"
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

      click_link "Add Characteristic"
      select "Shirt size", :from => "segment_column[1]"
      select "equals", :from => "segment_operator[1]"
      select "medium", :from => "segment_value[1]"

      click_button "Find segment"

      expect_content "Users in this segment: 5"
    end

    before(:each) do
      @characteristic = FactoryGirl.create(:characteristic, :discrete, name: "Shirt size", allowed_values: %w(small medium large), demo: @demo)
      @locations = []
      3.times { @locations << FactoryGirl.create(:location, demo: @demo) }

      @expected_segment_users = []
      characteristic_hash = {@characteristic.id => 'medium'}
      5.times { @expected_segment_users << FactoryGirl.create(:user, :claimed, characteristics: characteristic_hash, location: @locations[0], demo: @demo) }

      4.times { FactoryGirl.create(:user, :claimed, characteristics: characteristic_hash, tickets: 15, demo: @demo) }
      3.times { FactoryGirl.create(:user, :claimed, location: @locations[0], tickets: 15, demo: @demo) }

      crank_dj_clear
    end

    context "and no users in that segment have tickets" do
      it "should say so", :js => true do
        visit admin_demo_raffles_path(@demo, as: an_admin)
        segment_users

        click_button "Pick a winner"
        expect_no_winner_text
      end
    end

    context "and some users in that segment have tickets" do
      before(:each) do
        @expected_segment_users.each_with_index do |user, i|
          user.update_attributes(tickets: i * 3)
        end

        crank_dj_clear
      end

      it "should select a user pseudorandomly proportional to how many tickets they have", :js => true do
        Demo.any_instance.stubs(:rand).with(30).returns(0, 2, 3, 8, 9, 17, 18, 29)
        visit admin_demo_raffles_path(@demo, as: an_admin)
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

  def expect_winner_line(winner)
    s = "And the winner is...#{winner.name} (#{winner.email})"
    expect_content s
  end

  def expect_no_winner_text
    expect_content "Nobody has any tickets, so nobody is a winner. Or everybody is."
  end

end
