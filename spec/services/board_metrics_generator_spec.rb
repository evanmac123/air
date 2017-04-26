require 'spec_helper'

describe BoardMetricsGenerator do
  describe ".set_cache" do
    it "only sets the cache for the current demo if site admin" do
      sa = FactoryGirl.create(:site_admin)
      generator = BoardMetricsGenerator.new([sa.demo])

      BoardMetricsGenerator.expects(:new).with([sa.demo]).returns(generator)
      BoardMetricsGenerator.any_instance.expects(:update_metrics_caches)

      BoardMetricsGenerator.set_cache(sa)
    end

    it "sets the cache for all current_user's demos if client admin" do
      ca = FactoryGirl.create(:client_admin)
      second_board = FactoryGirl.create(:demo, name: "second board")
      ca.demos << second_board
      generator = BoardMetricsGenerator.new(ca.demos)

      BoardMetricsGenerator.expects(:new).with(ca.demos.select(:id)).returns(generator)

      BoardMetricsGenerator.any_instance.expects(:update_metrics_caches)

      BoardMetricsGenerator.set_cache(ca)
    end
  end

  describe "#update_metrics_caches" do
    it "calls update_metrics_caches_for_board for each board" do
      ca = FactoryGirl.create(:client_admin)
      second_board = FactoryGirl.create(:demo, name: "second board")
      ca.demos << second_board
      generator = BoardMetricsGenerator.new(ca.demos)

      generator.expects(:update_metrics_caches_for_board).twice

      generator.update_metrics_caches
    end

    describe "#update_metrics_caches_for_board" do
      it "calls sets the cache for designated queries" do
        sa = FactoryGirl.create(:site_admin)
        generator = BoardMetricsGenerator.new([sa.demo])

        queries.each do |query|
          query.any_instance.expects(:set_cached_query).times(3)
        end

        generator.send(:update_metrics_caches_for_board, sa.demo)
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
