require 'spec_helper'

describe Reports::TileStatsReport do

  before do
    Timecop.freeze(Time.new(1990))
  end

  after do
    Timecop.return
  end

  def build_data
    client_admin = FactoryGirl.create(:client_admin)
    users = FactoryGirl.create_list(:user, 5, demo: client_admin.demo)

    @tile = FactoryGirl.create(:multiple_choice_tile, multiple_choice_answers: ["a", "b", "c"], correct_answer_index: 0, demo: client_admin.demo)

    @tile.tile_viewings.create(user_id: client_admin.id)
    users.each do |user|
      @tile.tile_viewings.create(user_id: user.id, created_at: Time.current + 1.day)
    end

    @tile.tile_completions.create(user_id: client_admin, answer_index: 0)
    users[0..2].each do |user|
      @tile.tile_completions.create(user_id: user.id, answer_index: 0, created_at: Time.current + 1.day)
    end

    @tile.tile_user_notifications.create(creator: client_admin, message: "message", subject: "subject", scope_cd: 0, delivered_at: Time.current - 1.day, recipient_count: 5)
  end

  describe "#data" do
    it "compiles correct data" do
      build_data

      tile_stats_report = Reports::TileStatsReport.new(tile_id: @tile.id)
      tile = tile_stats_report.tile
      data = tile_stats_report.data

      expect(data[:id]).to eq(tile.id)
      expect(data[:datePosted]).to eq(tile.activated_at)

      expect(data[:dateSent]).to eq(tile.sent_at)

      expect(data[:headline]).to eq(tile.headline)

      expect(data[:question]).to eq(tile.question)

      expect(data[:totalViews]).to eq(tile.total_viewings_count)

      expect(data[:uniqueViews]).to eq(tile.unique_viewings_count)

      expect(data[:totalCompletions]).to eq(tile.tile_completions_count)

      expect(data[:surveyChart]).to eq(tile.survey_chart)

      expect(data[:activityGridUpdatePath]).to eq(tile_stats_report.client_admin_tile_tile_stats_grids_path(tile))

      expect(data[:activityGridUpdatesPollingPath]).to eq(tile_stats_report.new_completions_count_client_admin_tile_tile_stats_grids_path(tile))

      expect(data[:tileActivityGridTypes]).to eq(GridQuery::TileActions::GRID_TYPES.invert)

      expect(data[:chartId]).to eq("tileActivityChart")

      expect(data[:chartSeriesNames]).to eq(["People Viewed", "People Completed"])

      expect(data[:chartTemplate]).to eq("loginActivityTilesDigestTemplate")

      expect(data[:tileMessageOptionsForScope]).to eq(TileUserNotification.options_for_scope_cd)

      expect(data[:tileMessageOptionsForAnswers]).to eq(TileUserNotification.options_for_answers(tile: tile))

      expect(data[:defaultNotificationRecipientCount]).to eq(tile_stats_report.send(:default_notification_recipient_count))

      expect(data[:tileUserNotifications]).to eq(tile_stats_report.send(:tile_user_notifications_for_report))

      expect(data[:tileActivitySeries]).to eq(tile_stats_report.send(:tile_activity_series))

      expect(data[:linkClickStats]).to eq({})
      expect(data[:hasLinkTracking]).to eq(false)
    end
  end

  describe "private" do
    describe "#tile_activity_series" do
      it "asks Charts::TileViewsAndCompletionsChart to to return a series of unique_views and total_completions for the tile" do
        build_data
        tile_stats_report = Reports::TileStatsReport.new(tile_id: @tile.id)
        tile = tile_stats_report.tile
        chart = Charts::TileViewsAndCompletionsChart.new({ tile: tile })
        tile_stats_report.stubs(:hide_second_series_by_default!)

        Charts::TileViewsAndCompletionsChart.expects(:new).with({ tile: tile }).once.returns(chart)

        chart.expects(:attributes).with(["unique_views", "total_completions"]).returns(stub_everything)

        tile_stats_report.send(:tile_activity_series)
      end

      it "makes the second series hidden" do
        build_data
        tile_stats_report = Reports::TileStatsReport.new(tile_id: @tile.id)
        chart = tile_stats_report.send(:tile_activity_series)

        expect(chart[:series][1][:visible]).to be(false)
      end
    end

    describe "#default_notification_recipient_count" do
      it "asks TileUserNotification to return a recipient_count based on a given tile" do
        build_data
        tile_stats_report = Reports::TileStatsReport.new(tile_id: @tile.id)

        TileUserNotification.expects(:default_recipient_count).with({ tile: tile_stats_report.tile }).once

        tile_stats_report.send(:default_notification_recipient_count)
      end
    end
  end
end
