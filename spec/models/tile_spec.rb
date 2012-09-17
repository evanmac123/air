require 'spec_helper'

describe Tile do
  it { should belong_to(:demo) }
  it { should have_many(:prerequisites) }
  it { should have_many(:prerequisite_tiles) }
  it { should have_many(:rule_triggers) }
  it { should have_one(:survey_trigger) }
 
  describe "#due?" do
    it "should tell me whether a tile is within the window of opportunity" do
      Demo.find_each { |f| f.destroy }
      demo = FactoryGirl.create :demo
      a = FactoryGirl.create :tile, :demo => demo
      past = 1.hour.ago
      future = 1.hour.from_now
      ################ NO TIMES SET  #######################
      a.start_time = nil
      a.end_time = nil
      a.should be_due
      a.save!
      Tile.after_start_time_and_before_end_time.should == [a]
      
      ################ HAS START TIME ONLY #################
      a.start_time = past
      a.end_time = nil
      a.should be_due
      a.save!
      Tile.after_start_time_and_before_end_time.should == [a]

      a.start_time = future
      a.end_time = nil
      a.should_not be_due
      a.save!
      Tile.after_start_time_and_before_end_time.should == []

      ################# HAS END TIME ONLY ##################
      a.start_time = nil
      a.end_time = past
      a.should_not be_due
      a.save!
      Tile.after_start_time_and_before_end_time.should == []

      a.start_time = nil
      a.end_time = future
      a.should be_due
      a.save!
      Tile.after_start_time_and_before_end_time.should == [a]

      ############## HAS START AND END TIME ################
      a.start_time = past
      a.end_time = future
      a.should be_due
      a.save!
      Tile.after_start_time_and_before_end_time.should == [a]

      a.start_time = past
      a.end_time = past
      a.should_not be_due
      a.save!
      Tile.after_start_time_and_before_end_time.should == []

      a.start_time = future 
      a.end_time = future
      a.should_not be_due
      a.save!
      Tile.after_start_time_and_before_end_time.should == []
    end
  end

  describe "due_ids" do
    it "should tell me the ids of all the due tiles" do
      Demo.find_each {|f| f.destroy}
      # Too early
      too_early = FactoryGirl.create(:tile, name: 'early', start_time: 1.minute.from_now)
      too_early.should_not be_due

      # Too late
      too_late = FactoryGirl.create(:tile, name: 'late', end_time: 1.minute.ago)
      too_late.should_not be_due

      # Just right
      just_right = FactoryGirl.create(:tile, name: 'right', start_time: 1.minute.ago, end_time: 1.minute.from_now)
      just_right.should be_due

      # due_ids
      Tile.due_ids.count.should == 1
    end
  end
  
  describe "displayable_to_user" do 
    before(:each) do
      Demo.find_each {|f| f.destroy}
      @fun = FactoryGirl.create(:demo, name: 'Fun')
      @not_fun = FactoryGirl.create(:demo, name: 'Not so Fun')
      @leah = FactoryGirl.create(:user, name: 'Leah', demo: @fun)
      @water_plants = FactoryGirl.create(:tile, demo: @fun, name: 'Water plants')
      @already_watered = FactoryGirl.create(:tile_completion, tile: @water_plants, user: @leah)
      @wash = FactoryGirl.create(:tile, demo: @fun, name: 'Wash the Dishes')
      @dry = FactoryGirl.create(:tile, demo: @not_fun, name: 'Dry the Dishes')
      @color_after_washing = FactoryGirl.create(:tile, demo: @fun, name: 'Choose a beautiful color for your wall')

      # two tiles that don't need to be done right now
      @shovel_snow = FactoryGirl.create(:tile, demo: @fun, start_time: 5.months.from_now)
      @spring_cleaning = FactoryGirl.create(:tile, demo: @fun, end_time: 4.months.ago)
      Tile.count.should == 6
    end

    it "should only display current tiles that have not been completed yet" do
      tiles = Tile.displayable_to_user(@leah)
      tiles.length.should == 3
      tiles.should include(@wash)
      tiles.should include(@color_after_washing)
      # Note that water plants will show up as its last time to display, since it's been completed
      tiles.should include(@water_plants)

    end
    
    it "should only display tiles whose prerequisites have been completed" do
      # Set up a prerequisite
      Prerequisite.create!(tile: @color_after_washing, prerequisite_tile: @wash)
      tiles = Tile.displayable_to_user(@leah)
      tiles.length.should == 2
      tiles.should include (@wash)
      tiles.should include (@water_plants)
      tiles.should_not include(@color_after_washing)
    end
  end

  describe "satisfiable to a particular user" do
    before(:each) do
      Demo.find_each {|f| f.destroy}
      @fun = FactoryGirl.create(:demo, name: 'A Good Time')
      @mud_bath = FactoryGirl.create(:tile, name: 'Mud Bath', demo: @fun)
      @leah = FactoryGirl.create(:user, name: 'Leah Eckles', demo: @fun)
      @take_a_bath = FactoryGirl.create(:rule, demo: @fun)
      FactoryGirl.create(:rule_trigger, rule: @take_a_bath, tile: @mud_bath)
    end

    it "looks good to the average user" do
      tiles = Tile.satisfiable_to_user(@leah)
      tiles.count.should == 1
      tiles.first.should == @mud_bath
    end
  end

  describe "satisfiable by a good many things" do
    before(:each) do
      Demo.find_each {|f| f.destroy}
      @fun = FactoryGirl.create(:demo, name: 'A Good Time')
      @mud_bath = FactoryGirl.create(:tile, name: 'Mud Bath', demo: @fun)
      @sponge_bath = FactoryGirl.create(:tile, name: 'Sponge Bath', demo: @fun)
      @hot_shower = FactoryGirl.create(:tile, name: 'Hot Shower', demo: @fun)

      # Make rules and rule triggers for mud_bath and sponge_bath
      @take_mud_bath = FactoryGirl.create(:rule, demo: @fun)
      FactoryGirl.create(:rule_trigger, rule: @take_mud_bath, tile: @mud_bath)
      @take_sponge_bath = FactoryGirl.create(:rule, demo: @fun)
      FactoryGirl.create(:rule_trigger, rule: @take_sponge_bath, tile: @sponge_bath)
    end

    it "is satisfiable by some rule" do 
      tiles = Tile.satisfiable_by_trigger_table('trigger_rule_triggers')
      tiles.count.should == 2
      tiles.should include(@mud_bath)
      tiles.should include(@sponge_bath)
    end

    it "is satisfiable by a particular rule" do 
      tiles_1 = Tile.satisfiable_by_rule(@take_sponge_bath) 
      tiles_1.should == [@sponge_bath]
      tiles_2 = Tile.satisfiable_by_rule(@take_mud_bath) 
      tiles_2.should == [@mud_bath]
    end

    it "is satisfiable to a particular user by a particular rule" do
      leah = FactoryGirl.create(:user, demo: @fun, name: 'Leah')
      tiles_before = Tile.satisfiable_by_rule_to_user(@take_mud_bath, leah)
      tiles_before.should == [@mud_bath]
      completion = FactoryGirl.create(:tile_completion, tile: @mud_bath, user: leah)
      tiles_after = Tile.satisfiable_by_rule_to_user(@take_mud_bath, leah.reload)
      tiles_after.should be_empty
    end

    it "satisfies a tile for a user" do

      janice = FactoryGirl.create(:user, demo: @fun, name: 'Janice')
      TileCompletion.count.should == 0
      janice.satisfy_tiles_by_rule(@take_mud_bath, 'web')
      TileCompletion.count.should == 1
      TileCompletion.first.tile.should == @mud_bath
      TileCompletion.first.user.should == janice
    end
  end

  describe "set position within demo" do
    before(:each) do
      @fun = FactoryGirl.create(:demo, name: 'Fun')
      @something_else = FactoryGirl.create(:demo, name: 'Something Else')
      5.times do
        FactoryGirl.create(:tile, demo: @something_else)
      end
      @leah = FactoryGirl.create(:user, demo: @fun, name: 'Leah')
      # Tiles
      @one = FactoryGirl.create(:tile, demo: @fun)
      @two = FactoryGirl.create(:tile, demo: @fun)
      @three = FactoryGirl.create(:tile, demo: @fun)
      @four = FactoryGirl.create(:tile, demo: @fun)
      # Mark one tile as completed--it will still show up as displayable because it has not been
      # displayed 'one_final_time'
      @completion = FactoryGirl.create(:tile_completion, user: @leah, tile: @two)
      2.times do
        FactoryGirl.create(:tile, demo: @something_else)
      end
    end
    
    it "should order by position" do
      tiles = Tile.displayable_to_user(@leah)
      tiles.should == [@one, @two, @three, @four]
      expected = [@two, @four, @three, @one]
      params = Hash.new
      params[:tile] = expected.map do |tile|
        tile.id.to_s
      end
      Tile.set_position_within_demo(@fun, params[:tile])
      tiles = Tile.displayable_to_user(@leah)
      tiles.should == expected

    end
  end

  describe "Bulk Complete" do
    before(:each) do
      Demo.find_each { |f| f.destroy }
      @fun = FactoryGirl.create(:demo, name: 'Fun')
      @not_fun = FactoryGirl.create(:demo, name: 'Not Fun')
      @stretch = FactoryGirl.create(:tile, demo: @fun, name: 'Stretch')
      @sip = FactoryGirl.create(:tile, demo: @fun, name: 'Sip')
      @breathe = FactoryGirl.create(:tile, demo: @fun, name: 'Breathe')

      @lucy  = FactoryGirl.create(:user, demo: @fun, name: 'Lucy')
      @james = FactoryGirl.create(:user, demo: @fun, name: 'James')
      @reath = FactoryGirl.create(:user, demo: @not_fun, name: 'Reath')
      @benji = FactoryGirl.create(:user, demo: @not_fun, name: 'Benji')

      @random_email = "nothing@sucks_more.org"
    end

    it "completes only tiles for users in this demo" do
      emails = [@reath.email, @lucy.email, @random_email]
      Tile.bulk_complete(@fun.id, @stretch.id, emails)
      TileCompletion.count.should == 1
      TileCompletion.first.user.should == @lucy
      TileCompletion.first.tile.should == @stretch
    end

    it "does no completions if blank string sent" do 
      emails = []
      Tile.bulk_complete(@fun.id, @stretch.id, emails)
      TileCompletion.count.should == 0
    end
  end

  describe "Reset Tiles" do
    before(:each) do 
      Demo.find_each { |f| f.destroy }
      @fast = FactoryGirl.create(:demo, name: 'Fast Game')
      @slow = FactoryGirl.create(:demo, name: 'Slow Game')
      @fast_tile = FactoryGirl.create(:tile, demo: @fast)
      @slow_tile = FactoryGirl.create(:tile, demo: @slow)
      @leah = FactoryGirl.create(:site_admin, name: 'Leah')
      @fast_completion = FactoryGirl.create(:tile_completion, tile: @fast_tile, user: @leah)
      @slow_completion = FactoryGirl.create(:tile_completion, tile: @slow_tile, user: @leah)
    end
    it "resets Leah's tiles for one demo only" do
      TileCompletion.count.should == 2
      Tile.reset_tiles_for_user_within_an_arbitrary_demo(@leah, @fast)
      TileCompletion.count.should == 1
      TileCompletion.first.should == @slow_completion
    end
  end
end
