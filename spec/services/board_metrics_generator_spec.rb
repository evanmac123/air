require 'spec_helper'

describe BoardMetricsGenerator do
  describe ".set_cache" do
    it "only sets the cache for the current demo" do
      ca = FactoryBot.create(:client_admin)
      generator = BoardMetricsGenerator.new(board: ca.demo)

      BoardMetricsGenerator.expects(:new).with(board: ca.demo).returns(generator)
      BoardMetricsGenerator.any_instance.expects(:update_metrics_caches_for_board)

      BoardMetricsGenerator.set_cache(board: ca.demo)
    end
  end

  describe "#update_metrics_caches" do
    describe "#update_metrics_caches_for_board" do
      it "calls sets the cache for designated queries" do
        ca = FactoryBot.create(:client_admin)
        generator = BoardMetricsGenerator.new(board: ca.demo)

        queries.each do |query|
          query.any_instance.expects(:set_cached_query).times(3)
        end

        generator.update_metrics_caches_for_board
      end
    end
  end

  def queries
    [
      Charts::Queries::BoardUniqueTileViews,
      Charts::Queries::BoardUniqueTileCompletions,
      Charts::Queries::BoardUniqueLoginActivity,
      Charts::Queries::BoardTotalTileViews,
      Charts::Queries::BoardTilesPosted,
      Charts::Queries::BoardDigestsSent
    ]
  end
end
