require 'spec_helper'

describe Tile do
  it { should belong_to(:demo) }
  it { should have_many(:prerequisites) }
  it { should have_many(:prerequisite_tiles) }
  it { should have_many(:rule_triggers) }
  it { should have_one(:survey_trigger) }
  it { should ensure_inclusion_of(:status).in_array(Tile::STATUS) }

  describe 'finders based on status' do
    it 'should return the correct tiles for each status type in the specified demo' do
      last_digest_sent_at = 3.days.ago.at_midnight
      demo = FactoryGirl.create :demo, tile_digest_email_sent_at: last_digest_sent_at

      # These guys hold just the id's, not the entire objects
      draft   = []
      archive = []
      active  = []
      digest  = []

      (1..3).each do |i|
        # Note that all of these tiles qualify for "digest" tiles because they are created after the last digest email
        # was sent => We can test that only "active" tiles go out in the digest email
        draft   << FactoryGirl.create(:tile, demo: demo, status: Tile::DRAFT,   created_at: last_digest_sent_at + i.minutes).id
        archive << FactoryGirl.create(:tile, demo: demo, status: Tile::ARCHIVE, created_at: last_digest_sent_at + i.minutes).id

        # These 'active' tiles were created *before* the last digest email => should not also be considered "digest" tiles
        active << FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE, created_at: last_digest_sent_at - i.minutes).id

        # These 'active' tiles were created *after* the last digest email => should also be considered "digest" tiles
        tile = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE, created_at: last_digest_sent_at + i.minutes).id
        active << tile
        digest << tile
      end

      # Create some tiles of each type that belong to a different demo
      bad_demo = FactoryGirl.create :demo, tile_digest_email_sent_at: last_digest_sent_at
      (1..2).each do |i|
        FactoryGirl.create(:tile, demo: bad_demo, status: Tile::DRAFT,   created_at: last_digest_sent_at + i.minutes).id
        FactoryGirl.create(:tile, demo: bad_demo, status: Tile::ARCHIVE, created_at: last_digest_sent_at + i.minutes).id

        FactoryGirl.create(:tile, demo: bad_demo, status: Tile::ACTIVE, created_at: last_digest_sent_at - i.minutes).id
        FactoryGirl.create(:tile, demo: bad_demo, status: Tile::ACTIVE, created_at: last_digest_sent_at + i.minutes).id
      end

      demo.draft_tiles.pluck(:id).sort.should   == draft.sort
      demo.archive_tiles.pluck(:id).sort.should == archive.sort
      demo.active_tiles.pluck(:id).sort.should  == active.sort
      demo.digest_tiles.pluck(:id).sort.should  == digest.sort
    end
  end

  describe 'expired tiles' do
    let(:demo) { FactoryGirl.create :demo }

    let!(:not_relevant_tiles) do  # Don't need a specific variable for these; just create once instead of for each test
      FactoryGirl.create(:tile, demo: demo, status: Tile::DRAFT,   end_time: Date.yesterday)  # Draft
      FactoryGirl.create(:tile, demo: demo, status: Tile::ARCHIVE, end_time: Date.yesterday)  # Archive

      FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE,  end_time: Date.tomorrow)   # End time in future
      FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE)                             # No end time => 'forever'
    end

    let!(:expired){ FactoryGirl.create_list(:tile, 3, demo: demo, status: Tile::ACTIVE, end_time: Date.yesterday) }

    it "#expired returns a list of tiles that have expired, i.e. whose 'end_time' is < 'current_time'" do
      Tile.expired.pluck(:id).sort.should == expired.collect(&:id).sort
    end

    it "#archive_if_expired archives tiles that have expired" do
      expired.each { |tile| tile.status.should == Tile::ACTIVE }
      Tile.archive_if_expired
      expired.each { |tile| tile.reload.status.should == Tile::ARCHIVE }
    end
  end

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

  describe ".due_ids" do
    it "should tell me the ids of all the due tiles" do
      Demo.find_each {|f| f.destroy}
      # Too early
      too_early = FactoryGirl.create(:tile, headline: 'early', start_time: 1.minute.from_now)
      too_early.should_not be_due

      # Too late
      too_late = FactoryGirl.create(:tile, headline: 'late', end_time: 1.minute.ago)
      too_late.should_not be_due

      # Just right
      just_right = FactoryGirl.create(:tile, headline: 'right', start_time: 1.minute.ago, end_time: 1.minute.from_now)
      just_right.should be_due

      # due_ids
      Tile.due_ids.count.should == 1
    end
  end
  
  describe ".displayable_to_user" do 
    before(:each) do
      Demo.find_each {|f| f.destroy}
      @fun = FactoryGirl.create(:demo, name: 'Fun')
      @not_fun = FactoryGirl.create(:demo, name: 'Not so Fun')
      @leah = FactoryGirl.create(:user, name: 'Leah', demo: @fun)
      @water_plants = FactoryGirl.create(:tile, demo: @fun, headline: 'Water plants')
      @already_watered = FactoryGirl.create(:tile_completion, tile: @water_plants, user: @leah)
      @wash = FactoryGirl.create(:tile, demo: @fun, headline: 'Wash the Dishes')
      @dry = FactoryGirl.create(:tile, demo: @not_fun, headline: 'Dry the Dishes')
      @color_after_washing = FactoryGirl.create(:tile, demo: @fun, headline: 'Choose a beautiful color for your wall')

      # two tiles that don't need to be done right now
      @shovel_snow = FactoryGirl.create(:tile, demo: @fun, start_time: 5.months.from_now)
      @spring_cleaning = FactoryGirl.create(:tile, demo: @fun, end_time: 4.months.ago)

      # And finally, a couple of tiles that have been archived
      @archived_wash = FactoryGirl.create(:tile, demo: @fun, headline: 'Archived Wash the Dishes', status: Tile::ARCHIVE)
      @archived_dry = FactoryGirl.create(:tile, demo: @not_fun, headline: 'Archived Dry the Dishes', status: Tile::ARCHIVE)

      Tile.count.should == 8
    end

    it "should only display current tiles that have not been completed yet" do
      tiles = Tile.displayable_to_user(@leah)
      tiles.length.should == 3
      tiles.should include(@wash)
      tiles.should include(@color_after_washing)
      # Note that water plants will show up as its last time to display, since it's been completed
      tiles.should include(@water_plants)
    end

    it "should not display current tiles that have been archived" do
      tiles = Tile.displayable_to_user(@leah)
      tiles.length.should == 3
      tiles.should_not include(@archived_wash)
      tiles.should_not include(@archived_dry)
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

  describe "#first_rule" do
    it "should return nil for a tile with no rule triggers" do
      FactoryGirl.create(:tile).first_rule.should be_nil
    end

    it "should return the first rule associated through a rule trigger, if such exists" do
      first_trigger = FactoryGirl.create(:rule_trigger)
      tile = first_trigger.tile
      3.times { FactoryGirl.create(:rule_trigger, tile: tile) }
      tile.first_rule.should == first_trigger.rule
    end
  end

  describe "#appears_client_created" do
    it "is true if the tile has supporting content and a question" do
      tile = FactoryGirl.create(:tile, :client_created)
      tile.appears_client_created.should be_true

      tile.update_attributes(supporting_content: nil)
      tile.appears_client_created.should be_false

      tile.update_attributes(supporting_content: "support", question: nil)
      tile.appears_client_created.should be_false
    end
  end

  describe "satisfiable to a particular user" do
    before(:each) do
      Demo.find_each {|f| f.destroy}
      @fun = FactoryGirl.create(:demo, name: 'A Good Time')
      @mud_bath = FactoryGirl.create(:tile, headline: 'Mud Bath', demo: @fun)
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
      @mud_bath = FactoryGirl.create(:tile, headline: 'Mud Bath', demo: @fun)
      @sponge_bath = FactoryGirl.create(:tile, headline: 'Sponge Bath', demo: @fun)
      @hot_shower = FactoryGirl.create(:tile, headline: 'Hot Shower', demo: @fun)

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
      @stretch = FactoryGirl.create(:tile, demo: @fun, headline: 'Stretch')
      @sip = FactoryGirl.create(:tile, demo: @fun, headline: 'Sip')
      @breathe = FactoryGirl.create(:tile, demo: @fun, headline: 'Breathe')

      @lucy  = FactoryGirl.create(:user, demo: @fun, name: 'Lucy')
      @james = FactoryGirl.create(:user, demo: @fun, name: 'James')
      @reath = FactoryGirl.create(:user, demo: @not_fun, name: 'Reath')
      @benji = FactoryGirl.create(:user, demo: @not_fun, name: 'Benji')

      @random_email = "nothing@sucks_more.org"
    end

    it "completes only tiles for users in this demo" do
      emails = [@reath.email, @lucy.email, @random_email]
      Tile.bulk_complete(@fun.id, @stretch.id, emails)
      crank_dj_clear
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

  describe "Tiles with all_required" do
    before(:each) do
      Demo.find_each { |f| f.destroy }
      @fun = FactoryGirl.create(:demo, name: 'F U N')
      @leah = FactoryGirl.create(:user, name: 'Leah', demo: @fun)
      @tile = FactoryGirl.create(:tile, headline: 'Tile with Require All', demo: @fun, poly: true)
      @rule_1 = FactoryGirl.create(:rule, demo: @fun)
      @rule_2 = FactoryGirl.create(:rule, demo: @fun)
      @trigger_1 = FactoryGirl.create(:rule_trigger, tile: @tile, rule: @rule_1)
      @trigger_2 = FactoryGirl.create(:rule_trigger, tile: @tile, rule: @rule_2)
    end

    it "should satisfy the rule only after both rules are satisfied" do
      Tile.satisfiable_to_user(@leah).should == [@tile]
      @tile.all_rule_triggers_satisfied_to_user(@leah).should be_false
      Act.count.should == 0
      # Create one of the required acts to satisfy the rule
      FactoryGirl.create(:act, user: @leah, rule: @rule_1) 
      @tile.all_rule_triggers_satisfied_to_user(@leah).should be_false
      Act.count.should == 1
      Tile.satisfiable_to_user(@leah.reload).should == [@tile]
      # Create the second act, so now it should actually be satisfied
      FactoryGirl.create(:act, user: @leah, rule: @rule_2) 
      @tile.all_rule_triggers_satisfied_to_user(@leah).should be_true
      Act.count.should == 3 # two acts and one tile completion
      TileCompletion.count.should == 1
      completion = TileCompletion.first
      completion.user.should == @leah
      completion.tile.should == @tile
      Tile.satisfiable_to_user(@leah.reload).should be_empty
    end
  end
end
