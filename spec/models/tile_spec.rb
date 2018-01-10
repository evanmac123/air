require 'spec_helper'

describe Tile do
  it { is_expected.to belong_to(:demo) }
  it { is_expected.to belong_to(:creator) }
  it { is_expected.to have_many(:tile_viewings) }
  it { is_expected.to have_many(:user_viewers) }
  it { is_expected.to have_many(:guest_user_viewers) }
  it { is_expected.to validate_inclusion_of(:status).in_array(Tile::STATUS) }

  describe "after_save" do
    let(:tile) { FactoryBot.create(:tile) }
    describe "#reindex" do
      it "reindexes tile if should_reindex? returns true" do
        tile.expects(:should_reindex?).returns(true)
        tile.expects(:reindex)

        tile.save
      end

      it "does not reindex tile if should_reindex? returns false" do
        tile.expects(:should_reindex?).returns(false)
        tile.expects(:reindex).never

        tile.save
      end
    end
  end

  describe "before_save" do
    let(:tile) { FactoryBot.create(:tile) }

    describe "#prep_image_processing" do
      describe "when image has not been changed" do
        it "does not call method prep_image_processing" do
          tile.expects(:prep_image_processing).never

          tile.save
        end
      end

      describe "when image has been updated" do
        it "calls prep_image_processing" do
          tile.expects(:prep_image_processing).once

          tile.remote_media_url = "remote_media_url"
          tile.save
        end
      end
    end
  end

  describe "#prep_image_processing" do
    let(:tile) { FactoryBot.create(:tile) }

    it "calls #validate_remote_media_url if remote_media_url is present" do
      tile.expects(:validate_remote_media_url).once
      tile.remote_media_url = "remote_media_url"

      tile.send(:prep_image_processing)
    end

    it "sets thumbnail_processing and image_processing to true if remote_media_url is present" do
      tile.thumbnail_processing = false
      tile.image_processing = false

      tile.remote_media_url = "remote_media_url"
      tile.send(:prep_image_processing)

      expect(tile.thumbnail_processing).to eq(true)
      expect(tile.image_processing).to eq(true)
    end

    it "does not set thumbnail_processing and image_processing to true if remote_media_url is not present"  do
      tile.thumbnail_processing = false
      tile.image_processing = false

      tile.remote_media_url = nil
      tile.send(:prep_image_processing)

      expect(tile.thumbnail_processing).to eq(false)
      expect(tile.image_processing).to eq(false)
    end
  end

  describe "#validate_remote_media_url" do
    let(:tile) { FactoryBot.create(:tile) }

    it "sets remote_media_url to nil if remote_media_url is greater than Tile.MAX_REMOTE_MEDIA_URL_LENGTH" do
      long_remote_media_url = "s" * (Tile::MAX_REMOTE_MEDIA_URL_LENGTH + 1)

      tile.remote_media_url = long_remote_media_url
      tile.send(:validate_remote_media_url)

      expect(tile.remote_media_url).to eq(nil)
    end

    it "does not change the remote_media_url if it is <= the Tile.MAX_REMOTE_MEDIA_URL_LENGTH" do
      long_remote_media_url = "s" * (Tile::MAX_REMOTE_MEDIA_URL_LENGTH)

      tile.remote_media_url = long_remote_media_url
      tile.send(:validate_remote_media_url)

      expect(tile.remote_media_url).to eq(long_remote_media_url)
    end
  end

  context "incomplete drafts" do
    let(:demo){Demo.new}
    LONG_TEXT  =  "*" * (Tile::MAX_SUPPORTING_CONTENT_LEN + 1)
    it "can be created with just  headline" do
      tile = Tile.new
      tile.status = Tile::DRAFT
      tile.headline = "headliner"
      expect(tile.valid?).to be true
    end
    it "can be created with just  image" do
      tile = Tile.new
      tile.status = Tile::DRAFT
      tile.remote_media_url = "image.png"
      expect(tile.valid?).to be true
    end

    it "cannot be created if headline and image missing" do
      tile = Tile.new(question_type: Tile::QUIZ)
      tile.headline = nil
      tile.remote_media_url = nil
      expect(tile.valid?).to be false
    end

    it "is invalid in type is quiz with no correct answer " do
      tile  = FactoryBot.build(:tile, question_type: Tile::QUIZ, question_subtype: Tile::MULTIPLE_CHOICE, correct_answer_index: -1)
      expect(tile.valid?).to be false
    end

   it "is isn't fully assembeld is quiz with no correct answer " do
      tile  = FactoryBot.create(:tile, status: Tile::DRAFT, question_type: Tile::QUIZ, question_subtype: Tile::MULTIPLE_CHOICE, correct_answer_index: -1)
      expect(tile.is_fully_assembled?).to be false
    end
    it "cannot set to active if incomplete" do
      tile  = FactoryBot.create :tile, status: Tile::ACTIVE
      tile.remote_media_url = nil
      expect(tile.valid?).to be false
    end

    it "cannot be posted if missing image" do
      tile  = FactoryBot.create :tile, status: Tile::DRAFT
      tile.remote_media_url = nil
      tile.status = Tile::ACTIVE
      expect(tile.save).to be false
    end

    it "can be saved as draft if supporting content len > specfied max" do
      tile  = FactoryBot.create :tile, status: Tile::DRAFT, supporting_content: LONG_TEXT
      expect(tile.save).to be true
    end

    it "cannot be posted if supporting content len > specfied max" do
      tile  = FactoryBot.create :tile, status: Tile::DRAFT
      tile.supporting_content = LONG_TEXT
      tile.status = Tile::ACTIVE
      expect(tile.save).to be false
    end
  end



  context "status and activated_at" do

    it "forbids updating activated_at when unarchiving tiles be default" do
      tile  = FactoryBot.create :tile, status: Tile::ARCHIVE
      expect(tile.activated_at_reset_allowed?).to be_falsey
    end

    it "doesnt change activated_at on un-archival if not explicitly set" do
      tile  = FactoryBot.create :tile, status: Tile::ARCHIVE, activated_at: 1.month.ago
      expect{tile.status=Tile::ACTIVE;tile.save}.to_not change{tile.activated_at}
    end

    it "allows updating activated_at when unarchiving tiles when explicitly set" do
      tile  = FactoryBot.create :tile, status: Tile::ARCHIVE
      tile.allow_activated_at_reset
      expect(tile.activated_at_reset_allowed?).to be_truthy
    end

    it "updates activated_at if the status changes from DRAFT to ACTIVE" do
      tile = FactoryBot.create :tile, status: Tile::DRAFT
      expect{tile.status=Tile::ACTIVE; tile.save}.to change{tile.activated_at}
    end
  end

  describe "handle_unarchive" do
    it "allows activated_at reset if allow digest flag is true" do
      tile  = FactoryBot.create :tile, status: Tile::ARCHIVE
      tile.handle_unarchived(Tile::ACTIVE, "true")
      expect(tile.activated_at_reset_allowed?).to be_truthy
    end


    it "prevents activated_at reset if allow digest flag is false" do
      tile  = FactoryBot.create :tile, status: Tile::ARCHIVE
      tile.handle_unarchived(Tile::ACTIVE, "false")
      expect(tile.activated_at_reset_allowed?).to be_falsey
    end

  end



  describe ".update_status" do
    it "doesn't change activated_it when status is active but allowdigest is false " do
      tile  = FactoryBot.create :tile, status: Tile::ARCHIVE, activated_at: 1.month.ago
      expect{ tile.update_status({"status" => "active", "redigest" => "false"}) }.to_not change{tile.activated_at}
    end

    it "doesn't change activated_it when status is active but allowdigest is false " do
      tile  = FactoryBot.create :tile, status: Tile::ARCHIVE, activated_at: 1.month.ago
      expect{ tile.update_status({"status" => "active"}) }.to_not change{tile.activated_at}
    end
  end


  describe 'finders based on status' do
    # The test below was written first and exercises all tile-status combinations pretty thoroughly.
    # We then decided to not initially set a demo's 'tile_digest_email_sent_at' => all 'active' tiles should
    # go out in the inaugural digest email. And that, my friend, is what this sucker tests.
    it "#digest should return all active tiles if a digest email has yet to be sent" do
      demo = FactoryBot.create :demo

      active  = FactoryBot.create_list :tile, 4, demo: demo
      archive = FactoryBot.create_list :tile, 2, demo: demo, status: Tile::ARCHIVE

      expect(demo.digest_tiles(nil).pluck(:id).sort).to eq(active.collect(&:id).sort)
    end

    it 'should return the correct tiles for each status type in the specified demo' do
      last_digest_sent_at = 3.days.ago.at_midnight
      demo = FactoryBot.create :demo, tile_digest_email_sent_at: last_digest_sent_at

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
        draft   << FactoryBot.create(:tile, demo: demo, status: Tile::DRAFT,   activated_at: last_digest_sent_at + i.minutes).id
        archive << FactoryBot.create(:tile, demo: demo, status: Tile::ARCHIVE, activated_at: last_digest_sent_at + i.minutes).id

        # These 'active' tiles were created *before* the last digest email => should not also be considered "digest" tiles
        active << FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE, activated_at: last_digest_sent_at - i.minutes).id

        # These 'active' tiles were created *after* the last digest email => should also be considered "digest" tiles
        tile = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE, activated_at: last_digest_sent_at + i.minutes).id
        active << tile
        digest << tile
      end

      # Create some tiles of each type that belong to a different demo
      bad_demo = FactoryBot.create :demo, tile_digest_email_sent_at: last_digest_sent_at
      (1..2).each do |i|
        FactoryBot.create(:tile, demo: bad_demo, status: Tile::DRAFT,   activated_at: last_digest_sent_at + i.minutes).id
        FactoryBot.create(:tile, demo: bad_demo, status: Tile::ARCHIVE, activated_at: last_digest_sent_at + i.minutes).id

        FactoryBot.create(:tile, demo: bad_demo, status: Tile::ACTIVE, correct_answer_index: 0, activated_at: last_digest_sent_at - i.minutes).id
        FactoryBot.create(:tile, demo: bad_demo, status: Tile::ACTIVE, correct_answer_index: 0, activated_at: last_digest_sent_at + i.minutes).id
      end

      expect(demo.draft_tiles.pluck(:id).sort).to   eq(draft.sort)
      expect(demo.archive_tiles.pluck(:id).sort).to eq(archive.sort)
      expect(demo.active_tiles.pluck(:id).sort).to  eq(active.sort)
      expect(demo.digest_tiles(demo.tile_digest_email_sent_at).pluck(:id).sort).to  eq(digest.sort)
    end
  end

  context "status changes" do
    let(:user){FactoryBot.create(:user)}
    let(:demo) { FactoryBot.create :demo }
    let(:tile) { FactoryBot.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, user_created: true }

    it "triggers status change manager if status has changed" do
      tile.status = Tile::DRAFT
      SuggestedTileStatusChangeManager.any_instance.expects(:process)
      tile.save
    end

    it "does not trigger status change manager if status has not changed" do
      tile.question = "2B || !2B"
      SuggestedTileStatusChangeManager.any_instance.expects(:process).never
      tile.save
    end

    it "triggers status change manager on creation " do
      SuggestedTileStatusChangeManager.any_instance.expects(:process)
      FactoryBot.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, user_created: true
    end
  end

  it "setting or updating tile status updates the corresponding timestamps", broken: true do

    # Test setting status during tile creation

    time_1 = Time.zone.now
    Timecop.freeze(time_1)
    tile_1 = FactoryBot.create :tile, status: Tile::ACTIVE
    expect(tile_1.activated_at.to_s).to eq(time_1.to_s)
    expect(tile_1.archived_at).to be_nil

    tile_2 = FactoryBot.create :tile, status: Tile::ARCHIVE
    expect(tile_2.archived_at.to_s).to eq(time_1.to_s)
    expect(tile_2.activated_at).to be_nil

    tile_3 = FactoryBot.create :tile, status: Tile::DRAFT
    expect(tile_3.activated_at).to be_nil
    expect(tile_3.archived_at).to be_nil

    #Don't forget to verify that we can override the time-stamp assignments with FactoryBot.
    #Note: As per the sample output below (from a failing test) the time from the dbase contains
    #too much information for this test => just grab the first part of the date
    #expected: "2013-08-15" ; got: "2013-08-15 00:00:00 -0400"

    tile_4 = FactoryBot.create :tile, status: Tile::ACTIVE, activated_at: Date.tomorrow
    expect((tile_4.activated_at.to_s.split)[0]).to eq(Date.tomorrow.to_s)

    tile_5 = FactoryBot.create :tile, status: Tile::ARCHIVE
    tile_5.update_column(:archived_at,  Date.yesterday) #use set to skip callback that auto sets archived date
    expect((tile_5.archived_at.to_s.split)[0]).to eq(Date.yesterday.to_s)

    #------------------------------------------------

    # Test setting status via 'update_attributes'

    time_2 = time_1 + 1.minute
    Timecop.freeze(time_2)

    tile_1.update_attributes status: Tile::ARCHIVE
    expect(tile_1.activated_at.to_s).to eq(time_1.to_s)
    expect(tile_1.archived_at.to_s).to eq(time_2.to_s)

    tile_2.update_attributes status: Tile::ACTIVE
    expect(tile_2.activated_at.to_s).to eq(time_2.to_s)
    expect(tile_2.archived_at.to_s).to eq(time_1.to_s)

    #------------------------------------------------

    #Test setting status via assignment

    time_3 = time_2 + 1.minute
    Timecop.freeze(time_3)

    tile_1.status = Tile::ACTIVE
    expect(tile_1.archived_at.to_s).to eq(time_2.to_s)

    tile_2.status = Tile::ARCHIVE
    expect(tile_2.activated_at.to_s).to eq(time_2.to_s)

    Timecop.return
  end

  describe "satisfiable to a particular user" do
    before(:each) do
      Demo.find_each {|f| f.destroy}
      @fun = FactoryBot.create(:demo, name: 'A Good Time')
      @mud_bath = FactoryBot.create(:tile, headline: 'Mud Bath', demo: @fun)
      @leah = FactoryBot.create(:user, name: 'Leah Eckles', demo: @fun)
    end

    it "looks good to the average user" do
      tiles = Tile.satisfiable_to_user(@leah)
      expect(tiles.count).to eq(1)
      expect(tiles.first.id).to eq(@mud_bath.id)
    end
  end

  describe "#survey_chart" do
    it "should return array with right statistic" do
      tile = FactoryBot.create(:survey_tile,
                                question: "Do you belive in life after life",
                                multiple_choice_answers: ["Yes", "No"]
                               )
      FactoryBot.create(:tile_completion, tile: tile, answer_index: 0 )
      FactoryBot.create(:tile_completion, tile: tile, answer_index: 1 )
      FactoryBot.create(:tile_completion, tile: tile, answer_index: 1 )
      expect(tile.survey_chart).to eq([{"answer"=>"Yes", "number"=>1, "percent"=>33.33},
                                       {"answer"=>"No", "number"=>2, "percent"=>66.67}])
    end

  end

  describe '#search_data for songkick', search: true do
    let(:user) {FactoryBot.create(:user) }
    let(:demo) { FactoryBot.create(:demo) }
    let(:tile) { FactoryBot.create(:multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, user_created: true) }

    it 'should be indexed' do
      FactoryBot.create(:tile, headline: "Food")

      Tile.reindex

      expect(Tile.search("food").records.length).to eq(1)
    end

    context 'no channels on tile' do
      it 'should return a serializable hash of a tile object plus an empty string channels key/value' do
        expect(tile.search_data).to eql(tile.serializable_hash.merge({ channel_list: [], organization_name: tile.organization.try(:name)}))
      end
    end

    context 'channels on tile' do
      let(:tile_with_channels) { FactoryBot.create(:tile, :public) }

      it 'should return a serializable hash of a tile object plus channels containing comma separated channels' do
        tile_with_channels.channel_list.add("wellness")
        tile_with_channels.save

        expect(tile_with_channels.search_data).to eql(tile_with_channels.serializable_hash.merge({ channel_list: ["wellness"], organization_name: tile_with_channels.organization.try(:name)}))
      end
    end
  end

  describe "#should_reindex?" do
    let(:tile) { FactoryBot.create(:tile) }
    it "return true if headline changed" do
      tile.headline = "New Headline"
      expect(tile.should_reindex?).to be true
    end

    it "return true if supporting_content changed" do
      tile.supporting_content = "New Content"
      expect(tile.should_reindex?).to be true
    end

    it "return true if is_public changed" do
      tile.is_public = true
      expect(tile.should_reindex?).to be true
    end

    it "return true if status changed" do
      tile.status = "archive"
      expect(tile.should_reindex?).to be true
    end

    it "returns false otherwise" do
      tile.touch
      expect(tile.should_reindex?).to be false
    end
  end

  describe "#creation_source" do
    let(:tile) { FactoryBot.create(:tile) }
    context "client_admin" do
      it "defaults to client_admin_created" do
        expect(tile.creation_source).to eq(:client_admin_created)
      end

      it "maps enum 0 to client_admin_created" do
        res = tile.update_attributes(creation_source: 0)

        expect(res).to be true
        expect(tile.creation_source).to eq(:client_admin_created)
      end

      it "accepts :client_admin_created as valid entry" do
        res = tile.update_attributes(creation_source: :client_admin_created)

        expect(res).to be true
        expect(tile.creation_source).to eq(:client_admin_created)
      end
    end

    context "explore" do
      it "maps enum 1 to explore_created" do
        tile.update_attributes(creation_source: 1)

        expect(tile.creation_source).to eq(:explore_created)
      end

      it "accepts :explore_created as valid entry" do
        tile.update_attributes(creation_source: :explore_created)

        expect(tile.creation_source).to eq(:explore_created)
      end
    end

    context "suggestion_box" do
      it "maps enum 2 to suggestion_box_created" do
        tile.update_attributes(creation_source: 2)

        expect(tile.creation_source).to eq(:suggestion_box_created)
      end

      it "accepts :suggestion_box_created as valid entry" do
        tile.update_attributes(creation_source: :suggestion_box_created)

        expect(tile.creation_source).to eq(:suggestion_box_created)
      end
    end
  end

  describe "#airbo_created?" do
    let(:tile) { FactoryBot.build(:tile) }

    it "returns true if the tile's organization is marked as internal" do
      tile.stubs(:organization).returns(OpenStruct.new(internal: true))

      expect(tile.airbo_created?).to eq(true)
    end

    it "returns false if the tile does not have an organization" do
      tile.stubs(:organization).returns(nil)

      expect(tile.airbo_created?).to be_falsey
    end

    it "returns false if the tiles's organization is not marked as internal" do
      tile.stubs(:organization).returns(OpenStruct.new(internal: false))

      expect(tile.airbo_created?).to be_falsey
    end
  end

  describe "#airbo_community_created?" do
    let(:tile) { FactoryBot.build(:tile) }

    it "returns true if the tile's organization is not marked as internal" do
      tile.stubs(:organization).returns(OpenStruct.new(internal: false))

      expect(tile.airbo_community_created?).to eq(true)
    end

    it "returns false if the tile does not have an organization" do
      tile.stubs(:organization).returns(nil)

      expect(tile.airbo_community_created?).to be_falsey
    end

    it "returns false if the tiles's organization is marked as internal" do
      tile.stubs(:organization).returns(OpenStruct.new(internal: true))

      expect(tile.airbo_community_created?).to be_falsey
    end
  end
end
