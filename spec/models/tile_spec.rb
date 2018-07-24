require 'spec_helper'

describe Tile do
  # it { is_expected.to belong_to(:demo) }
  # it { is_expected.to belong_to(:creator) }
  # it { is_expected.to have_many(:tile_viewings) }
  # it { is_expected.to validate_inclusion_of(:status).in_array(Tile::STATUS) }
  #
  # describe "after_save" do
  #   let(:tile) { FactoryBot.create(:tile) }
  #   describe "#reindex" do
  #     it "reindexes tile if should_reindex? returns true" do
  #       tile.expects(:should_reindex?).returns(true)
  #       tile.expects(:reindex)
  #
  #       tile.save
  #     end
  #
  #     it "does not reindex tile if should_reindex? returns false" do
  #       tile.expects(:should_reindex?).returns(false)
  #       tile.expects(:reindex).never
  #
  #       tile.save
  #     end
  #   end
  # end
  #
  # describe "before_save" do
  #   let(:tile) { FactoryBot.create(:tile) }
  #
  #   describe "#prep_image_processing" do
  #     describe "when image has not been changed" do
  #       it "does not call method prep_image_processing" do
  #         tile.expects(:prep_image_processing).never
  #
  #         tile.save
  #       end
  #     end
  #
  #     describe "when image has been updated" do
  #       it "calls prep_image_processing" do
  #         tile.expects(:prep_image_processing).once
  #
  #         tile.remote_media_url = "remote_media_url"
  #         tile.save
  #       end
  #     end
  #   end
  # end
  #
  # describe "#prep_image_processing" do
  #   let(:tile) { FactoryBot.create(:tile) }
  #
  #   it "calls #validate_remote_media_url if remote_media_url is present" do
  #     tile.expects(:validate_remote_media_url).once
  #     tile.remote_media_url = "remote_media_url"
  #
  #     tile.send(:prep_image_processing)
  #   end
  #
  #   it "sets thumbnail_processing and image_processing to true if remote_media_url is present" do
  #     tile.thumbnail_processing = false
  #     tile.image_processing = false
  #
  #     tile.remote_media_url = "remote_media_url"
  #     tile.send(:prep_image_processing)
  #
  #     expect(tile.thumbnail_processing).to eq(true)
  #     expect(tile.image_processing).to eq(true)
  #   end
  #
  #   it "does not set thumbnail_processing and image_processing to true if remote_media_url is not present"  do
  #     tile.thumbnail_processing = false
  #     tile.image_processing = false
  #
  #     tile.remote_media_url = nil
  #     tile.send(:prep_image_processing)
  #
  #     expect(tile.thumbnail_processing).to eq(false)
  #     expect(tile.image_processing).to eq(false)
  #   end
  # end
  #
  # describe "#validate_remote_media_url" do
  #   let(:tile) { FactoryBot.create(:tile) }
  #
  #   it "sets remote_media_url to nil if remote_media_url is greater than Tile.MAX_REMOTE_MEDIA_URL_LENGTH" do
  #     long_remote_media_url = "s" * (Tile::MAX_REMOTE_MEDIA_URL_LENGTH + 1)
  #
  #     tile.remote_media_url = long_remote_media_url
  #     tile.send(:validate_remote_media_url)
  #
  #     expect(tile.remote_media_url).to eq(nil)
  #   end
  #
  #   it "does not change the remote_media_url if it is <= the Tile.MAX_REMOTE_MEDIA_URL_LENGTH" do
  #     long_remote_media_url = "s" * (Tile::MAX_REMOTE_MEDIA_URL_LENGTH)
  #
  #     tile.remote_media_url = long_remote_media_url
  #     tile.send(:validate_remote_media_url)
  #
  #     expect(tile.remote_media_url).to eq(long_remote_media_url)
  #   end
  # end
  #
  # context "incomplete tiles in plan" do
  #   let(:demo){ Demo.new }
  #   LONG_TEXT  =  "*" * (Tile::MAX_SUPPORTING_CONTENT_LEN + 1)
  #   it "can be created with just  headline" do
  #     tile = Tile.new
  #     tile.status = Tile::PLAN
  #     tile.headline = "headliner"
  #     expect(tile.valid?).to be true
  #   end
  #   it "can be created with just  image" do
  #     tile = Tile.new
  #     tile.status = Tile::PLAN
  #     tile.remote_media_url = "image.png"
  #     expect(tile.valid?).to be true
  #   end
  #
  #   it "cannot be created if headline and image missing" do
  #     tile = Tile.new(question_type: Tile::QUIZ)
  #     tile.headline = nil
  #     tile.remote_media_url = nil
  #     expect(tile.valid?).to be false
  #   end
  #
  #   it "is invalid in type is quiz with no correct answer " do
  #     tile  = FactoryBot.build(:tile, question_type: Tile::QUIZ, question_subtype: Tile::MULTIPLE_CHOICE, correct_answer_index: -1)
  #     expect(tile.valid?).to be false
  #   end
  #
  #  it "is isn't fully assembeld is quiz with no correct answer " do
  #     tile  = FactoryBot.create(:tile, status: Tile::PLAN, question_type: Tile::QUIZ, question_subtype: Tile::MULTIPLE_CHOICE, correct_answer_index: -1)
  #     expect(tile.is_fully_assembled?).to be false
  #   end
  #   it "cannot set to active if incomplete" do
  #     tile  = FactoryBot.create :tile, status: Tile::ACTIVE
  #     tile.remote_media_url = nil
  #     expect(tile.valid?).to be false
  #   end
  #
  #   it "cannot be posted if missing image" do
  #     tile  = FactoryBot.create :tile, status: Tile::PLAN
  #     tile.remote_media_url = nil
  #     tile.status = Tile::ACTIVE
  #     expect(tile.save).to be false
  #   end
  #
  #   it "can be saved as draft if supporting content len > specfied max" do
  #     tile  = FactoryBot.create :tile, status: Tile::PLAN, supporting_content: LONG_TEXT
  #     expect(tile.save).to be true
  #   end
  #
  #   it "cannot be posted if supporting content len > specfied max" do
  #     tile  = FactoryBot.create :tile, status: Tile::PLAN
  #     tile.supporting_content = LONG_TEXT
  #     tile.status = Tile::ACTIVE
  #     expect(tile.save).to be false
  #   end
  # end
  #
  # context "status changes" do
  #   let(:user){ FactoryBot.create(:user) }
  #   let(:demo) { FactoryBot.create :demo }
  #   let(:tile) { FactoryBot.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, creation_source: Tile.creation_sources[:suggestion_box_created] }
  #
  #   it "triggers status change manager if status has changed" do
  #     tile.status = Tile::DRAFT
  #     SuggestedTileStatusChangeManager.any_instance.expects(:process)
  #     tile.save
  #   end
  #
  #   it "does not trigger status change manager if status has not changed" do
  #     tile.question = "2B || !2B"
  #     SuggestedTileStatusChangeManager.any_instance.expects(:process).never
  #     tile.save
  #   end
  #
  #   it "triggers status change manager on creation " do
  #     SuggestedTileStatusChangeManager.any_instance.expects(:process)
  #     FactoryBot.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, creation_source: Tile.creation_sources[:suggestion_box_created]
  #   end
  # end
  #
  # describe "#survey_chart" do
  #   it "should return array with right statistic" do
  #     tile = FactoryBot.create(:survey_tile,
  #                               question: "Do you belive in life after life",
  #                               multiple_choice_answers: ["Yes", "No"]
  #                              )
  #     FactoryBot.create(:tile_completion, tile: tile, answer_index: 0 )
  #     FactoryBot.create(:tile_completion, tile: tile, answer_index: 1 )
  #     FactoryBot.create(:tile_completion, tile: tile, answer_index: 1 )
  #     expect(tile.survey_chart).to eq([{"answer"=>"Yes", "number"=>1, "percent"=>33.33},
  #                                      {"answer"=>"No", "number"=>2, "percent"=>66.67}])
  #   end
  #
  # end
  #
  # describe '#search_data for songkick', search: true do
  #   let(:user) {FactoryBot.create(:user) }
  #   let(:demo) { FactoryBot.create(:demo) }
  #   let(:tile) { FactoryBot.create(:multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user) }
  #
  #   it 'should be indexed' do
  #     FactoryBot.create(:tile, headline: "Food")
  #
  #     Tile.reindex
  #
  #     expect(Tile.search("food", fields: [:headline]).records.length).to eq(1)
  #   end
  # end
  #
  # describe "#should_reindex?" do
  #   let(:tile) { FactoryBot.create(:tile) }
  #   it "return true if headline changed" do
  #     tile.headline = "New Headline"
  #     expect(tile.should_reindex?).to be true
  #   end
  #
  #   it "return true if supporting_content changed" do
  #     tile.supporting_content = "New Content"
  #     expect(tile.should_reindex?).to be true
  #   end
  #
  #   it "return true if is_public changed" do
  #     tile.is_public = true
  #     expect(tile.should_reindex?).to be true
  #   end
  #
  #   it "return true if status changed" do
  #     tile.status = Tile::ARCHIVE
  #     expect(tile.should_reindex?).to be true
  #   end
  #
  #   it "returns false otherwise" do
  #     tile.touch
  #     expect(tile.should_reindex?).to be false
  #   end
  # end
  #
  # describe "#creation_source" do
  #   let(:tile) { FactoryBot.create(:tile) }
  #   context "client_admin" do
  #     it "defaults to client_admin_created" do
  #       expect(tile.creation_source).to eq(:client_admin_created)
  #     end
  #
  #     it "maps enum 0 to client_admin_created" do
  #       res = tile.update_attributes(creation_source: 0)
  #
  #       expect(res).to be true
  #       expect(tile.creation_source).to eq(:client_admin_created)
  #     end
  #
  #     it "accepts :client_admin_created as valid entry" do
  #       res = tile.update_attributes(creation_source: :client_admin_created)
  #
  #       expect(res).to be true
  #       expect(tile.creation_source).to eq(:client_admin_created)
  #     end
  #   end
  #
  #   context "explore" do
  #     it "maps enum 1 to explore_created" do
  #       tile.update_attributes(creation_source: 1)
  #
  #       expect(tile.creation_source).to eq(:explore_created)
  #     end
  #
  #     it "accepts :explore_created as valid entry" do
  #       tile.update_attributes(creation_source: :explore_created)
  #
  #       expect(tile.creation_source).to eq(:explore_created)
  #     end
  #   end
  #
  #   context "suggestion_box" do
  #     it "maps enum 2 to suggestion_box_created" do
  #       tile.update_attributes(creation_source: 2)
  #
  #       expect(tile.creation_source).to eq(:suggestion_box_created)
  #     end
  #
  #     it "accepts :suggestion_box_created as valid entry" do
  #       tile.update_attributes(creation_source: :suggestion_box_created)
  #
  #       expect(tile.creation_source).to eq(:suggestion_box_created)
  #     end
  #   end
  # end
  #
  # describe "#airbo_created?" do
  #   let(:tile) { FactoryBot.build(:tile) }
  #
  #   it "returns true if the tile's organization is marked as internal" do
  #     tile.stubs(:organization).returns(OpenStruct.new(internal: true))
  #
  #     expect(tile.airbo_created?).to eq(true)
  #   end
  #
  #   it "returns false if the tile does not have an organization" do
  #     tile.stubs(:organization).returns(nil)
  #
  #     expect(tile.airbo_created?).to be_falsey
  #   end
  #
  #   it "returns false if the tiles's organization is not marked as internal" do
  #     tile.stubs(:organization).returns(OpenStruct.new(internal: false))
  #
  #     expect(tile.airbo_created?).to be_falsey
  #   end
  # end
  #
  # describe "#airbo_community_created?" do
  #   let(:tile) { FactoryBot.build(:tile) }
  #
  #   it "returns true if the tile's organization is not marked as internal" do
  #     tile.stubs(:organization).returns(OpenStruct.new(internal: false))
  #
  #     expect(tile.airbo_community_created?).to eq(true)
  #   end
  #
  #   it "returns false if the tile does not have an organization" do
  #     tile.stubs(:organization).returns(nil)
  #
  #     expect(tile.airbo_community_created?).to be_falsey
  #   end
  #
  #   it "returns false if the tiles's organization is marked as internal" do
  #     tile.stubs(:organization).returns(OpenStruct.new(internal: true))
  #
  #     expect(tile.airbo_community_created?).to be_falsey
  #   end
  # end

  describe '#display_explore_campaigns' do
    before do
      demo = FactoryBot.build(:demo)
      @campaign = FactoryBot.build(:campaign, active: true, public_explore: true)
      FactoryBot.create_list(
        :tile,
        3,
        headline: 'Testing tile',
        campaign: @campaign,
        demo: demo,
        status: Tile::ACTIVE,
        is_public: true
      )
    end

    context 'no current_board' do
      before do
        @explore_tiles = JSON.parse(Tile.display_explore_campaigns)
        @result_campaign = @explore_tiles.first
        @camp_tiles = @result_campaign['tiles']
      end

      it 'returns single campaign active, public campaign when no current_board' do
        expect(@explore_tiles.count).to eq(1)
        expect(@result_campaign['name']).to eq(@campaign[:name])
        expect(@result_campaign['description']).to eq(@campaign[:description])
        expect(@result_campaign['ongoing']).to eq(@campaign[:ongoing])
      end

      it 'contains correct amount of tiles belonging to given campaign' do
        expect(@camp_tiles.count).to eq(3)
      end

      it 'contains correct information for each tile' do
        @camp_tiles.each do |result_tile|
          expected_tile = Tile.find(result_tile['id'])
          expect(expected_tile.headline).to eq(result_tile['headline'])
          expect(expected_tile.created_at.as_json).to eq(result_tile['created_at'])
          expect(expected_tile.remote_media_url).to eq(result_tile['thumbnail'])
          expect(expected_tile.thumbnail_content_type).to eq(result_tile['thumbnailContentType'])
          expect("/explore/copy_tile?path=via_explore_page_tile_view&tile_id=#{expected_tile.id}").to eq(result_tile['copyPath'])
          expect("/explore/tile/#{expected_tile.id}").to eq(result_tile['tileShowPath'])
        end
      end
    end

    context 'returning private campaigns' do
      before do
        organization = FactoryBot.create(:organization)
        @current_board = FactoryBot.create(:demo, organization: organization)
        @private_campaign = FactoryBot.create(
          :campaign,
          demo: @current_board,
          active: true,
          private_explore: true
        )
        FactoryBot.create(
          :tile,
          headline: 'Testing tile',
          campaign: @private_campaign,
          demo: @current_board,
          status: Tile::ACTIVE
        )
      end

      it 'returns both public and private campaigns with current_board' do
        explore_tiles = JSON.parse(Tile.display_explore_campaigns(@current_board))

        expect(explore_tiles.count).to eq(2)
        expect(explore_tiles.first['id']).to eq(@campaign.id)
        expect(explore_tiles.last['id']).to eq(@private_campaign.id)
      end

      it 'only returns public campaigns if no current_board is given' do
        explore_tiles = JSON.parse(Tile.display_explore_campaigns)

        expect(explore_tiles.count).to eq(1)
        expect(explore_tiles.first['id']).to eq(@campaign.id)
      end

      it 'contains correct tile information' do
        explore_tiles = JSON.parse(Tile.display_explore_campaigns(@current_board))

        expect(explore_tiles.last['tiles'].count).to eq(1)
        explore_tiles.last['tiles'].each do |result_tile|
          expected_tile = Tile.find(result_tile['id'])
          expect(expected_tile.headline).to eq(result_tile['headline'])
          expect(expected_tile.created_at.as_json).to eq(result_tile['created_at'])
          expect(expected_tile.remote_media_url).to eq(result_tile['thumbnail'])
          expect(expected_tile.thumbnail_content_type).to eq(result_tile['thumbnailContentType'])
          expect("/explore/copy_tile?path=via_explore_page_tile_view&tile_id=#{expected_tile.id}").to eq(result_tile['copyPath'])
          expect("/explore/tile/#{expected_tile.id}").to eq(result_tile['tileShowPath'])
        end
      end
    end
  end
end
