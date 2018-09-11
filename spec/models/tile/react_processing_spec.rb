require 'spec_helper'

describe Tile::ReactProcessing do
  STATUS_DATE = {
    "plan" => "plan_date",
    "active" => "activated_at",
    "archive" => "archived_at",
  }

  describe "#get_query_statement" do
    it "returns proper query statement for time" do
      ['year', 'month'].each do |time|
        ['plan', 'active', 'archive'].each do |status|
          result = Tile::ReactProcessing.get_query_statement(time, status)
          expected = "extract(#{time} from #{STATUS_DATE[status]})"

          expect(expected).to eq(result)
        end
      end
    end

    it "returns campaign_id if year or month is not passed" do
      result = Tile::ReactProcessing.get_query_statement('campaign', 'status')
      expected = "campaign_id"

      expect(expected).to eq(result)
    end
  end

  describe "#build_query" do
    it "returns query statement to be chained to larger statement" do
      result = Tile::ReactProcessing.build_query("", "plan", ["year", "1"])
      expected = "extract(year from plan_date) = 1 AND "

      expect(expected).to eq(result)
    end

    it "returns first argument if sortType is passed as first element in sort" do
      expected = "should be returned"
      result = Tile::ReactProcessing.build_query(expected, "plan", ["sortType", "date-sort"])

      expect(expected).to eq(result)
    end
  end

  describe "#get_edit_tile_filters" do
    it "returns SQL statement for filters passed" do
      filter = "year=2&campaign=1&sortType=date-sort"
      result = Tile::ReactProcessing.get_edit_tile_filters(status: 'plan', filter: filter)
      expected = "extract(year from plan_date) = 2 AND campaign_id = 1"

      expect(expected).to eq(result)
    end
  end

  describe "#sanitize_sort_filter" do
    it "returns proper SQL order by sort params passed" do
      result = Tile::ReactProcessing.sanitize_sort_filter(["sortType=date-sort"], "ASC", "plan")
      expected = "plan_date ASC"

      expect(expected).to eq(result)
    end

    it "returns empty string if sortType is not a filter given" do
      result = Tile::ReactProcessing.sanitize_sort_filter(["year=2", "month=3"], "DESC", "archive")
      expected = ""

      expect(expected).to eq(result)
    end
  end

  describe "#get_edit_tile_sort" do
    it "returns proper SQL order by sort params passed" do
      result = Tile::ReactProcessing.get_edit_tile_sort(filter: "sortType=date-sort&year=2&month=1", status: "plan")
      expected = "plan_date ASC"

      expect(expected).to eq(result)
    end

    it "returns order by position if sortType is not passed in filter" do
      result = Tile::ReactProcessing.get_edit_tile_sort(filter: "year=2&month=1", status: "plan")
      expected = "position DESC"

      expect(expected).to eq(result)
    end
  end

  describe '#sanitize_for_edit_flow' do
    it 'sanitizes Tile query result to contain exactly what react expects for edit' do
      tiles = FactoryBot.create_list(:tile, 1)
      result_tile = Tile::ReactProcessing.sanitize_for_edit_flow(tiles, 1).first
      expected_tile = Tile.find(result_tile['id'])

      expect(expected_tile.headline).to eq(result_tile['headline'])
      expect(expected_tile.remote_media_url).to eq(result_tile['thumbnail'])
      expect("/client_admin/tiles/#{expected_tile.id}/edit").to eq(result_tile['editPath'])
      expect("/client_admin/tiles/#{expected_tile.id}").to eq(result_tile['tileShowPath'])
      expect(expected_tile.plan_date).to eq(result_tile["planDate"])
      expect(expected_tile.activated_at).to eq(result_tile["activeDate"])
      expect(expected_tile.archived_at).to eq(result_tile["archiveDate"])
      expect(expected_tile.is_fully_assembled?).to eq(result_tile["fullyAssembled"])
      expect(expected_tile.unique_viewings_count).to eq(result_tile["unique_views"])
      expect(expected_tile.total_viewings_count).to eq(result_tile["views"])
      expect(expected_tile.tile_completions_count).to eq(result_tile["completions"])
    end
  end

  describe '#sanitize_for_explore' do
    it 'sanitizes Tile query result to contain exactly what react expects for explore' do
      tiles = FactoryBot.create_list(:tile, 1)
      result_tile = Tile::ReactProcessing.sanitize_for_explore(tiles, 1).first
      expected_tile = Tile.find(result_tile['id'])

      expect(expected_tile.headline).to eq(result_tile['headline'])
      expect(expected_tile.remote_media_url).to eq(result_tile['thumbnail'])
      expect(expected_tile.thumbnail_content_type).to eq(result_tile['thumbnailContentType'])
      expect("/explore/copy_tile?path=via_explore_page_tile_view&tile_id=#{expected_tile.id}").to eq(result_tile['copyPath'])
      expect("/explore/tile/#{expected_tile.id}").to eq(result_tile['tileShowPath'])
    end
  end
end
