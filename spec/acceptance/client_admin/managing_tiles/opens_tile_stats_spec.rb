require 'acceptance/acceptance_helper'

feature "Client admin opens tile stats", js: true, type: :feature do

  let!(:demo) { FactoryBot.create :demo }
  let!(:client_admin) { FactoryBot.create :client_admin, demo: demo }
  let(:user_1) { FactoryBot.create(:user, demo: demo, name: 'One') }
  let(:user_2) { FactoryBot.create(:user, demo: demo, name: 'Two') }

  let!(:tile) { FactoryBot.create(:multiple_choice_tile,
    status: Tile::ACTIVE,
    demo: demo,
    activated_at: Time.current,
    headline: "Tile Headline",
    question: "Tile Question",
    multiple_choice_answers: ["A", "B", "C"],
    correct_answer_index: 0
  )}

  def create_user_data_for_sorting(tile)
    FactoryBot.create(:tile_completion, user: user_1, tile: tile, created_at: 10.minutes.from_now, answer_index: 0)
    FactoryBot.create(:tile_viewing, user: user_1, tile: tile, created_at: 11.minutes.from_now)

    FactoryBot.create(:tile_viewing, user: user_2, tile: tile, created_at: 61.minutes.from_now)
  end

  def open_stats(tile)
    visit client_admin_tiles_path(as: client_admin)

    within ".tile_thumbnail[data-tile-id='#{tile.id}']" do
      first('.js-open-tile-stats-modal').click
    end
  end

  describe "when tile stats modal is opened" do
    describe "when switching between tabs" do
      before do
        open_stats(tile)
      end

      it "should show the analytics tab" do
        within ".js-tile-stats-modal.open" do
          expect(page).to have_css('.js-tile-stats-modal-tab-content.analytics')
        end
      end

      it "should switch to the activity tab" do
        within ".js-tile-stats-modal.open" do
          click_link("Activity")
          expect(page).to have_css('.js-tile-stats-modal-tab-content.activity')
          expect(page).to_not have_css('.js-tile-stats-modal-tab-content.analytics')
        end
      end

      it "should switch back to the analytics tab" do
        within ".js-tile-stats-modal.open" do
          click_link("Activity")
          expect(page).to have_css('.js-tile-stats-modal-tab-content.activity')

          click_link("Analytics")
          expect(page).to have_css('.js-tile-stats-modal-tab-content.analytics')
          expect(page).to_not have_css('.js-tile-stats-modal-tab-content.activity')
        end
      end
    end

    describe "tile stats modal data" do
      before do
        create_user_data_for_sorting(tile)
        open_stats(tile)
      end

      describe "analytics tab" do
        before do
          expect(page).to have_css('.js-tile-stats-modal-tab-content.analytics')
        end

        it "should show the correct stats overview" do
          within ".action_type_block.date-posted" do
            expect_content("Date Posted")
          end

          within ".action_type_block.people-viewed" do
            expect_content("2 People Viewed")
          end

          within ".action_type_block.people-completed" do
            expect_content("1 Person Completed")
          end

          within ".chart-container.js-highcharts-chart" do
            expect(page).to have_css('.highcharts-container')
          end

          within ".table-title" do
            expect_content(tile.question)
          end

          within ".survey-chart-table" do
            table_data = page.all('tr').map(&:text)
            expect(table_data).to eq(["Answer People Percent", "A 1 100%", "B 0 0%", "C 0 0%"])
          end
        end
      end

      describe "activity tab" do
        before do
          click_link("Activity")
          expect(page).to have_css('.js-tile-stats-modal-tab-content.activity')
        end

        it "should show the correct activity data" do
          within ".js-tile-stats-modal.open" do
            expect(page).to have_content("Live")

            page.find('table')
            live_grid_data = page.all('tr').map(&:text)

            expect(live_grid_data[0]).to eq("Date Name Answer Views")
          end
        end
      end
    end
  end
end
