require 'spec_helper'

describe SuggestedTileStatusChangeManager do
  let(:user){FactoryBot.create(:user)}
  let(:demo) { FactoryBot.create :demo }
  describe "#process" do

    def mock_tile(suggestion_box_created:, status_changes:, creator: User.new)
      OpenStruct.new({
        suggestion_box_created?: suggestion_box_created,
        creator: creator,
        changes: {
          status: status_changes
        }
      })
    end

    def process_change_expectation(expected_method:, tile:)
      mgr = SuggestedTileStatusChangeManager.new(tile)
      mgr.expects(expected_method)
      mgr.process
    end

    def process_change_negation(expected_method:, tile:)
      mgr = SuggestedTileStatusChangeManager.new(tile)
      mgr.expects(expected_method).never
      mgr.process
    end

    context "user_submitted" do
      it "sends admin email if new record and status is USER_SUBMITTED" do
        tile = mock_tile(suggestion_box_created: true, status_changes: [nil, Tile::USER_SUBMITTED])

        process_change_expectation(expected_method: :send_submitted_email, tile: tile)
      end

      it "doesn't sends emails status not user_submitted" do
        tile = mock_tile(suggestion_box_created: true, status_changes: [nil, Tile::DRAFT])

        process_change_negation(expected_method: :send_submitted_email, tile: tile)
      end

      it "doesn't sends emails if it has no creator" do
        tile = mock_tile(suggestion_box_created: true, status_changes: [nil, Tile::USER_SUBMITTED], creator: nil)

        process_change_negation(expected_method: :send_submitted_email, tile: tile)
      end
    end

    context "accepted" do
      context "original status USER_SUBMITTED" do
        it "sends email if status is changed to PLAN" do
          tile = mock_tile(suggestion_box_created: true, status_changes: [Tile::USER_SUBMITTED, Tile::PLAN])

          process_change_expectation(expected_method: :send_acceptance_email, tile: tile)
        end

        it "doesn't send email if status has not changed to DRAFT" do
          tile = mock_tile(suggestion_box_created: true, status_changes: [Tile::USER_SUBMITTED, Tile::IGNORED])

          process_change_negation(expected_method: :send_acceptance_email, tile: tile)
        end
      end

      context "is not user created" do
        it "doesn't sends emails if creation source is not suggestion_box_created" do
          tile = mock_tile(suggestion_box_created: false, status_changes: [nil, Tile::DRAFT])

          process_change_negation(expected_method: :send_acceptance_email, tile: tile)
        end
      end

      it "doesn't sends emails if it has no creator" do
        tile = mock_tile(suggestion_box_created: true, status_changes: [Tile::USER_SUBMITTED, Tile::DRAFT], creator: nil)

        process_change_negation(expected_method: :send_acceptance_email, tile: tile)
      end
    end

    context "posted" do
      context "original status DRAFT" do
        it "sends email if status is change to ACTIVE" do
          tile = mock_tile(suggestion_box_created: true, status_changes: [Tile::DRAFT, Tile::ACTIVE])

          process_change_expectation(expected_method: :send_posted_email, tile: tile)
        end

        it "doesn't send email if status has not changed to ACTIVE" do
          tile = mock_tile(suggestion_box_created: true, status_changes: [Tile::DRAFT, Tile::IGNORED])

          process_change_negation(expected_method: :send_posted_email, tile: tile)
        end
      end

      it "doesn't sends emails original status not DRAFT" do
        tile = mock_tile(suggestion_box_created: true, status_changes: [nil, Tile::ACTIVE])

        process_change_negation(expected_method: :send_posted_email, tile: tile)
      end

      it "doesn't sends emails if has no creator" do
        tile = mock_tile(suggestion_box_created: true, status_changes: [Tile::DRAFT, Tile::ACTIVE], creator: nil)

        process_change_negation(expected_method: :send_posted_email, tile: tile)
      end
    end
  end
end
