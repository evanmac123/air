require 'spec_helper'


describe UserBoardMigrator do

  before do
    @board_a = FactoryGirl.create(:demo)
    @board_b = FactoryGirl.create(:demo)
    @users_a_only =[]
    @users_b_only =[]
    [50, 75, ].each do |point|
      @users_a_only << FactoryGirl.create(:user,  points: point, demo: @board_a)
    end

    [72, 57 ].each do |point|
      @users_b_only << FactoryGirl.create(:user, points: point, demo: @board_b)
    end
    @board_a_bms = @board_a.board_memberships
    @bard_b_bms= @board_b.board_memberships

    @migrator  = UserBoardMigrator.new(@users_a_only.map(&:id), @board_a.id, @board_b.id)

  end

  it "has empty summary" do
    @migrator.summary.results == []
  end


  describe "execute" do

    it "doesn't modify records during dry run" do
      expect {@migrator.execute}.to change{BoardMembership.count}.by(0)
    end

    it "deletes old board memberships" do
      expect {@migrator.execute(true)}.to change{@board_a.board_memberships.count}.by(-2)
    end

    it "updates new hoard memberships " do
      expect {@migrator.execute(true)}.to change{@board_a.board_memberships.count}.by(-2)
    end

    it "updates users points  " do
      expect {@migrator.execute(true)}.to change{@board_b.board_memberships.count}.by(2)
    end

    it "populates summary with correct values" do
      expect {@migrator.execute(true)}.to change{@migrator.summary.results.size}.by(2);
    end

    it "populates summary with correct values" do
      @migrator.execute(true)
      expect(@migrator.summary.results).to eq(
        [
          {
            :user=>"James Earl Jones",
            :starting_user_points=>50,
            :from_board_points=>0,
            :to_board_starting_points=>0,
            :final_user_points=>50,
            :to_board_points=>50
          },
          {
            :user=>"James Earl Jones",
            :starting_user_points=>75,
            :from_board_points=>0,
            :to_board_starting_points=>0,
            :final_user_points=>75,
            :to_board_points=>75
          }
        ])
    end

  end

end

