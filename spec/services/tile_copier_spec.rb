require 'spec_helper'

describe TileCopier do
  describe "#copy_tile" do
    let(:original_tile) { FactoryGirl.create(:tile, points: 10) }
    let(:copying_user)  { FactoryGirl.create(:client_admin) }

    describe "#copy_tile_from_explore" do
      let(:tile_copier)   { TileCopier.new(copying_user.demo, original_tile, copying_user) }

      it "delivers tile copied notification" do
        Mailer.expects(:delay_mail).with(:notify_creator_for_social_interaction, original_tile, copying_user, 'copied')

        tile_copier.copy_tile_from_explore
      end

      it "increments tile.copy_count" do
        original_tile.update_attribute(:copy_count, 10)
        tile_copier.copy_tile_from_explore

        expect(original_tile.copy_count).to eq(11)
      end

      it "sends explore tile creation ping" do
        TrackEvent.expects(:ping).with('Tile - New', { tile_source: "Explore Page" }, copying_user)

        tile_copier.copy_tile_from_explore
      end

      it "sets copy.creation_source" do
        copy = tile_copier.copy_tile_from_explore

        expect(copy.creation_source).to eq(:explore_created)
      end

      it "copies the correct data" do
        copy = tile_copier.copy_tile_from_explore

        data_that_should_be_copied.each do |field|
          expect(copy.send(field)).to eq(original_tile.send(field))
        end
      end

      it "sets correct new data" do
        copy = tile_copier.copy_tile_from_explore

        expect(copy.status).to eq(Tile::DRAFT)
        expect(copy.original_creator).to eq(original_tile.creator)
        expect(copy.original_created_at).to eq(original_tile.created_at)
        expect(copy.demo).to eq(copying_user.demo)
        expect(copy.creator).to eq(copying_user)
        expect(copy.remote_media_url).to eq(original_tile.image.url)
        expect(copy.media_source).to eq('tile-copy')
      end
    end

    describe "#copy_from_own_board" do
      let(:tile_copier)   { TileCopier.new(copying_user.demo, original_tile) }

      it "sends explore tile creation ping" do
        TrackEvent.expects(:ping).with('Tile - New', { tile_source: "Self Created - Duplicated" }, nil)

        tile_copier.copy_from_own_board
      end

      it "copies the correct data" do
        copy = tile_copier.copy_from_own_board

        data_that_should_be_copied.each do |field|
          expect(copy.send(field)).to eq(original_tile.send(field))
        end
      end

      it "sets correct new data" do
        copy = tile_copier.copy_from_own_board

        expect(copy.status).to eq(Tile::DRAFT)
        expect(copy.original_creator).to eq(original_tile.creator)
        expect(copy.original_created_at).to eq(original_tile.created_at)
        expect(copy.demo).to eq(copying_user.demo)
        expect(copy.creator).to eq(nil)
        expect(copy.remote_media_url).to eq(original_tile.image.url)
        expect(copy.media_source).to eq('tile-copy')
      end
    end
  end
  #
  # => Helpers
  #
  def data_that_should_be_copied
    [
      "correct_answer_index",
      "headline",
      "multiple_choice_answers",
      "points",
      "question",
      "embed_video",
      "supporting_content",
      "question_type",
      "question_subtype"
    ]
  end
end
