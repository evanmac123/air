require 'spec_helper'

describe Tile do
  it { should belong_to(:demo) }
  it { should belong_to(:creator) }
  it { should have_many(:rule_triggers) }
  it { should have_many(:tile_tags) }
  it { should ensure_inclusion_of(:status).in_array(Tile::STATUS) }

  describe 'finders based on status' do
    # The test below was written first and exercises all tile-status combinations pretty thoroughly.
    # We then decided to not initially set a demo's 'tile_digest_email_sent_at' => all 'active' tiles should
    # go out in the inaugural digest email. And that, my friend, is what this sucker tests.
    it "#digest should return all active tiles if a digest email has yet to be sent" do
      demo = FactoryGirl.create :demo

      active  = FactoryGirl.create_list :tile, 4, demo: demo
      archive = FactoryGirl.create_list :tile, 2, demo: demo, status: Tile::ARCHIVE

      demo.digest_tiles(nil).pluck(:id).sort.should == active.collect(&:id).sort
    end

    it 'should return the correct tiles for each status type in the specified demo' do
      last_digest_sent_at = 3.days.ago.at_midnight
      demo = FactoryGirl.create :demo, tile_digest_email_sent_at: last_digest_sent_at

      # These guys hold just the id's, not the entire objects
      draft   = []
      archive = []
      active  = []
      digest  = []

      (1..3).each do |i|
        # Note that all of these tiles kinda qualify for "digest" tiles because they are activated after the
        # last digest email was sent => We can test that only "active" tiles go out in the digest email.
        # And you could create, activate, and then archive a tile after the last digest email got sent but before the next
        # digest email goes out => Need to ensure that 'activated_at' alone does not get tile included in the digest email.
        draft   << FactoryGirl.create(:tile, demo: demo, status: Tile::DRAFT,   activated_at: last_digest_sent_at + i.minutes).id
        archive << FactoryGirl.create(:tile, demo: demo, status: Tile::ARCHIVE, activated_at: last_digest_sent_at + i.minutes).id

        # These 'active' tiles were created *before* the last digest email => should not also be considered "digest" tiles
        active << FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE, activated_at: last_digest_sent_at - i.minutes).id

        # These 'active' tiles were created *after* the last digest email => should also be considered "digest" tiles
        tile = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE, activated_at: last_digest_sent_at + i.minutes).id
        active << tile
        digest << tile
      end

      # Create some tiles of each type that belong to a different demo
      bad_demo = FactoryGirl.create :demo, tile_digest_email_sent_at: last_digest_sent_at
      (1..2).each do |i|
        FactoryGirl.create(:tile, demo: bad_demo, status: Tile::DRAFT,   activated_at: last_digest_sent_at + i.minutes).id
        FactoryGirl.create(:tile, demo: bad_demo, status: Tile::ARCHIVE, activated_at: last_digest_sent_at + i.minutes).id

        FactoryGirl.create(:tile, demo: bad_demo, status: Tile::ACTIVE, activated_at: last_digest_sent_at - i.minutes).id
        FactoryGirl.create(:tile, demo: bad_demo, status: Tile::ACTIVE, activated_at: last_digest_sent_at + i.minutes).id
      end

      demo.draft_tiles.pluck(:id).sort.should   == draft.sort
      demo.archive_tiles.pluck(:id).sort.should == archive.sort
      demo.active_tiles.pluck(:id).sort.should  == active.sort
      demo.digest_tiles(demo.tile_digest_email_sent_at).pluck(:id).sort.should  == digest.sort
    end
  end

  it "setting or updating tile status updates the corresponding timestamps" do

    # Test setting status during tile creation

    time_1 = Time.zone.now
    Timecop.freeze(time_1)

    tile_1 = FactoryGirl.create :tile, status: Tile::ACTIVE
    tile_1.activated_at.to_s.should == time_1.to_s
    tile_1.archived_at.should be_nil

    tile_2 = FactoryGirl.create :tile, status: Tile::ARCHIVE
    tile_2.archived_at.to_s.should == time_1.to_s
    tile_2.activated_at.should be_nil

    tile_3 = FactoryGirl.create :tile, status: Tile::DRAFT
    tile_3.activated_at.should be_nil
    tile_3.archived_at.should be_nil

    # Don't forget to verify that we can override the time-stamp assignments with FactoryGirl.
    # Note: As per the sample output below (from a failing test) the time from the dbase contains
    # too much information for this test => just grab the first part of the date
    # expected: "2013-08-15" ; got: "2013-08-15 00:00:00 -0400"

    tile_4 = FactoryGirl.create :tile, status: Tile::ACTIVE, activated_at: Date.tomorrow
    (tile_4.activated_at.to_s.split)[0].should == Date.tomorrow.to_s

    tile_5 = FactoryGirl.create :tile, status: Tile::ARCHIVE, archived_at: Date.yesterday
    (tile_5.archived_at.to_s.split)[0].should == Date.yesterday.to_s

    #------------------------------------------------

    # Test setting status via 'update_attributes'

    time_2 = time_1 + 1.minute
    Timecop.freeze(time_2)

    tile_1.update_attributes status: Tile::ARCHIVE
    tile_1.activated_at.to_s.should == time_1.to_s
    tile_1.archived_at.to_s.should == time_2.to_s

    tile_2.update_attributes status: Tile::ACTIVE
    tile_2.activated_at.to_s.should == time_2.to_s
    tile_2.archived_at.to_s.should == time_1.to_s

    #------------------------------------------------

    # Test setting status via assignment

    time_3 = time_2 + 1.minute
    Timecop.freeze(time_3)

    tile_1.status = Tile::ACTIVE
    tile_1.activated_at.to_s.should == time_3.to_s
    tile_1.archived_at.to_s.should == time_2.to_s

    tile_2.status = Tile::ARCHIVE
    tile_2.activated_at.to_s.should == time_2.to_s
    tile_2.archived_at.to_s.should == time_3.to_s

    Timecop.return
  end

  describe "activating and archiving tiles with 'start_time's and 'end_time's" do
    let(:demo) { FactoryGirl.create :demo }

    it "#activate_if_showtime activates tiles that are good to go" do
      good_to_go = FactoryGirl.create_list(:tile, 3, demo: demo, status: Tile::ARCHIVE, start_time: Time.now - 1.second)

      demo.tiles.activate_if_showtime

      good_to_go.each do |tile|
        tile.reload.status.should == Tile::ACTIVE
        tile.start_time.should be_nil
      end
    end

    it "#archive_if_curtain_call archives tiles that have expired" do
      expired = FactoryGirl.create_list(:tile, 3, demo: demo, status: Tile::ACTIVE, end_time: Time.now - 1.second)

      demo.tiles.archive_if_curtain_call

      expired.each do |tile|
        tile.reload.status.should == Tile::ARCHIVE
        tile.end_time.should be_nil
      end
    end
  end

  describe "#due?" do
    it "should tell me whether a tile is within the window of opportunity" do
      Demo.find_each { |f| f.destroy }
      demo = FactoryGirl.create :demo
      a = FactoryGirl.create(:tile, :demo => demo)
      # Effectively reload a under the right class (OldSchoolTile vs. Tile)
      a = Tile.find(a)
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

    it "should only display active, current tiles that have not been completed yet" do
      tiles = Tile.displayable_to_user(@leah)
      tiles.length.should == 2
      tiles.map(&:id).should include(@wash.id)
      tiles.map(&:id).should include(@color_after_washing.id)
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
    it "is true for KeywordTiles and MultipleChoiceTiles, but not OldSchoolTiles" do
      FactoryGirl.create(:keyword_tile).appears_client_created.should == true
      FactoryGirl.create(:multiple_choice_tile).appears_client_created.should == true
      FactoryGirl.create(:old_school_tile).appears_client_created.should == false
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
      tiles.first.id.should == @mud_bath.id
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
      tiles.map(&:id).should include(@mud_bath.id)
      tiles.map(&:id).should include(@sponge_bath.id)
    end

    it "is satisfiable by a particular rule" do
      tiles_1 = Tile.satisfiable_by_rule(@take_sponge_bath)
      tiles_1.map(&:id).should == [@sponge_bath.id]
      tiles_2 = Tile.satisfiable_by_rule(@take_mud_bath)
      tiles_2.map(&:id).should == [@mud_bath.id]
    end

    it "is satisfiable to a particular user by a particular rule" do
      leah = FactoryGirl.create(:user, demo: @fun, name: 'Leah')
      tiles_before = Tile.satisfiable_by_rule_to_user(@take_mud_bath, leah)
      tiles_before.map(&:id).should == [@mud_bath.id]
      completion = FactoryGirl.create(:tile_completion, tile: @mud_bath, user: leah)
      tiles_after = Tile.satisfiable_by_rule_to_user(@take_mud_bath, leah.reload)
      tiles_after.should be_empty
    end

    it "satisfies a tile for a user" do
      janice = FactoryGirl.create(:user, demo: @fun, name: 'Janice')
      TileCompletion.count.should == 0
      janice.satisfy_tiles_by_rule(@take_mud_bath)
      TileCompletion.count.should == 1
      TileCompletion.first.tile.id.should == @mud_bath.id
      TileCompletion.first.user.should == janice
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
      TileCompletion.first.tile_id.should == @stretch.id
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
      Tile.satisfiable_to_user(@leah).map(&:id).should == [@tile.id]
      @tile.all_rule_triggers_satisfied_to_user(@leah).should be_false
      Act.count.should == 0
      # Create one of the required acts to satisfy the rule
      FactoryGirl.create(:act, user: @leah, rule: @rule_1)
      @tile.all_rule_triggers_satisfied_to_user(@leah).should be_false
      Act.count.should == 1
      Tile.satisfiable_to_user(@leah.reload).map(&:id).should == [@tile.id]
      # Create the second act, so now it should actually be satisfied
      FactoryGirl.create(:act, user: @leah, rule: @rule_2)
      @tile.all_rule_triggers_satisfied_to_user(@leah).should be_true
      Act.count.should == 3 # two acts and one tile completion
      TileCompletion.count.should == 1
      completion = TileCompletion.first
      completion.user.should == @leah
      completion.tile_id.should == @tile.id
      Tile.satisfiable_to_user(@leah.reload).should be_empty
    end
  end

  describe "after save" do
    context "if a URL is specified that starts with http or https" do
      it "should leave it alone" do
        http_tile = FactoryGirl.create(:tile, link_address: "http://www.google.com")
        https_tile = FactoryGirl.create(:tile, link_address: "https://www.nsa.gov")

        http_tile.reload.link_address.should == 'http://www.google.com'
        https_tile.reload.link_address.should == 'https://www.nsa.gov'
      end
    end

    context "if a URL is specified with no protocol" do
      it "should prepend HTTP" do
        tile = FactoryGirl.create(:tile, link_address: 'google.com')
        tile.reload.link_address.should == 'http://google.com'

        tile.update_attributes(link_address: 'nsa.gov')
        tile.reload.link_address.should == 'http://nsa.gov'
      end
    end

    context "if no URL is specified" do
      it "should leave it blank" do
        nil_tile = FactoryGirl.create(:tile, link_address: nil)
        blank_tile = FactoryGirl.create(:tile, link_address: '')

        nil_tile.reload.link_address.should be_nil
        blank_tile.reload.link_address.should == ''
      end
    end
  end

  describe "#survey_chart" do
    it "should return array with right statistic" do
      tile = FactoryGirl.create(:survey_tile, \
        question: "Do you belive in life after life", \
        multiple_choice_answers: ["Yes", "No"])
      tc1 = FactoryGirl.create(:tile_completion, tile: tile, answer_index: 0 )
      tc2 = FactoryGirl.create(:tile_completion, tile: tile, answer_index: 1 )
      tc3 = FactoryGirl.create(:tile_completion, tile: tile, answer_index: 1 )
      tile.survey_chart.should == [{"answer"=>"Yes", "number"=>1, "percent"=>"33.33%"}, 
                                    {"answer"=>"No", "number"=>2, "percent"=>"66.67%"}]
    end
  end

  describe "image filenames" do
    def legacy_filename
      "Jerome_Smith.original.Screenshot-4.13.14.at.6.15.PM.png"
    end

    def make_legacy_tile
      tile = FactoryGirl.create(:multiple_choice_tile)
      tile.update_column(:image_file_name, legacy_filename) # No callbacks, no validations
      tile
    end

    it "should be normalized on creation" do
      tile = FactoryGirl.create(:multiple_choice_tile, image: File.open(Rails.root.join "spec/support/fixtures/tiles/cov'1.jpg"))
      tile.image_file_name.should == "cov-1.jpg"
    end

    it "should be normalized on save if changed" do
      tile = make_legacy_tile
      tile.image = File.open(Rails.root.join "spec/support/fixtures/tiles/cov'1.jpg")
      tile.save!

      tile.image_file_name.should == "cov-1.jpg"
    end

    it "should not be touched if the tile is saved for some other reason, but the filename is unchanged" do
      tile = make_legacy_tile

      tile.status = Tile::ACTIVE
      tile.save!

      tile.reload.image_file_name.should == legacy_filename
    end
  end
end
