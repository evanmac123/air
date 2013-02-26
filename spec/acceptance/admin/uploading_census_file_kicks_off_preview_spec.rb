require 'acceptance/acceptance_helper'

feature 'Uploading census file' do
  FIXTURE_PATH = Rails.root.join(*%w(spec support fixtures arbitrary_csv.csv))
  SHORT_FIXTURE_PATH = Rails.root.join(*%w(spec support fixtures short_arbitrary_csv.csv))

  def expect_csv_row_content(all_rows, expected_row_index)
    # We see the row we want, and only that row.
    all_rows.each_with_index do |row, i|
      if i == expected_row_index
        row.each {|cell| expect_content cell}
      else
        row.each {|cell| expect_no_content cell}
      end
    end
  end

  def expect_row_pagination(expected_rows)
    # Make sure we can page through the first rows_to_preview rows...
    0.upto(expected_rows.length - 1) do |i|
      expect_csv_row_content(expected_rows, i)
      click_link "Next"
    end

    # ...with a loop around to the end...
    expect_csv_row_content(expected_rows, 0)

    # ...and in reverse too.
    (expected_rows.length - 1).downto(0) do |i|
      click_link "Prev"
      expect_csv_row_content(expected_rows, i)
    end
  end

  scenario 'kicks off preview', js: true do
    object_key = MockS3.simulate_census_file_upload(FIXTURE_PATH)
    visit client_admin_bulk_upload_preview_path(object_key: object_key, as: an_admin)
    crank_dj_clear

    csv_rows = CSV.parse(File.read(FIXTURE_PATH))
    expected_rows = csv_rows[0, ClientAdmin::BulkUploadPreviewsController::ROWS_TO_PREVIEW]

    expect_row_pagination(expected_rows)
  end

  context "when there are fewer records than the max we can preview", js: true do
    it "should do this gracefully" do
      object_key = MockS3.simulate_census_file_upload(SHORT_FIXTURE_PATH)
      visit client_admin_bulk_upload_preview_path(object_key: object_key, as: an_admin)
      crank_dj_clear

      csv_rows = CSV.parse(File.read(SHORT_FIXTURE_PATH))
      expect_row_pagination(csv_rows)
    end
  end

  scenario "client admins can't do this (yet)" do
    visit client_admin_bulk_upload_path(as: a_client_admin)
    should_be_on activity_path
  end
end
