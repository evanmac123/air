require 'spec_helper'


describe UserBoardMigrator do

  before do
    @board_a = FactoryGirl.create(:demo)
    @board_b = FactoryGirl.create(:demo)
    @users_a =[]
    @users_b =[]

  end

  describe "execute" do
    context "with no common users between boards" do

      before do
        {"john"=> 50, "paul" =>75}.each do |name, point|
          @users_a << FactoryGirl.create(:user, name: name,   points: point, demo: @board_a)
        end

        {"mathew" => 72, "luke" => 57}.each do |name, point|
          @users_b << FactoryGirl.create(:user, name: name, points: point, demo: @board_b)
        end

        @board_a_bms = @board_a.board_memberships
        @bard_b_bms= @board_b.board_memberships
        @migrator  = UserBoardMigrator.new(@users_a.map(&:id), @board_a.id, @board_b.id)
      end

      it "doesn't modify records during dry run" do
        expect {@migrator.execute}.to change{BoardMembership.count}.by(0)
      end

      it "deletes old board memberships" do
        expect {@migrator.execute(true)}.to change{@board_a.board_memberships.count}.by(-2)
      end

      it "updates new hoard memberships " do
        expect {@migrator.execute(true)}.to change{@board_b.board_memberships.count}.by(2)
      end


      it "summary contains number of affected users" do
        expect {@migrator.execute(true)}.to change{@migrator.summary.results.size}.by(2);
      end

      it "populates summary with correct values" do
        @migrator.execute(true)
        expect(@migrator.summary.results).to eq(
          [
            {
              :user=>"john",
              :starting_user_points=>50,
              :from_board_points=>0,
              :to_board_starting_points=>0,
              :final_user_points=>50,
              :to_board_points=>50
            },
            {
              :user=>"paul",
              :starting_user_points=>75,
              :from_board_points=>0,
              :to_board_starting_points=>0,
              :final_user_points=>75,
              :to_board_points=>75
            }
          ])
      end
    end


    context "with common users between boards" do
      before do
        {"john"=> 50, "paul" =>75, "timothy" => 20}.each do |name, point|
          @users_a << FactoryGirl.create(:user, name: name,   points: point, demo: @board_a)
        end

        {"mathew" => 72, "luke" => 57}.each do |name, point|
          @users_b << FactoryGirl.create(:user, name: name, points: point, demo: @board_b)
        end

        @john = @users_a.select{|u|u.name =="john"}.first
        @paul = @users_a.select{|u|u.name =="paul"}.first

        FactoryGirl.create(:board_membership,user: @john, demo: @board_b, points: 0)
        FactoryGirl.create(:board_membership,user: @paul, demo: @board_b, points: 25)

        @board_a_bms = @board_a.board_memberships
        @bard_b_bms= @board_b.board_memberships
        @migrator  = UserBoardMigrator.new(@users_a.map(&:id), @board_a.id, @board_b.id)
      end

      it "doesn't modify records during dry run" do
        expect {@migrator.execute}.to change{BoardMembership.count}.by(0)
      end

      it "deletes old board memberships" do
        expect {@migrator.execute(true)}.to change{@board_a.board_memberships.count}.by(-3)
      end

      it "updates new hoard memberships " do
        expect {@migrator.execute(true)}.to change{@board_b.board_memberships.count}.by(1)
      end


      it "summary contains number of affected users" do
        expect {@migrator.execute(true)}.to change{@migrator.summary.results.size}.by(3);
      end

      it "populates summary with correct values" do
        @migrator.execute(true)
        expect(@migrator.summary.results).to eq(
          [
            {
              :user=>"john",
              :starting_user_points=>50,
              :from_board_points=>0,
              :to_board_starting_points=>0,
              :final_user_points=>50,
              :to_board_points=>50
            },
            {
              :user=>"paul",
              :starting_user_points=>75,
              :from_board_points=>0,
              :to_board_starting_points=>25,
              :final_user_points=>100,
              :to_board_points=>100
            } ,
            {
              :user=>"timothy",
              :starting_user_points=>20,
              :from_board_points=>0,
              :to_board_starting_points=>0,
              :final_user_points=>20,
              :to_board_points=>20
            }


          ])
      end
    end


  end
end

