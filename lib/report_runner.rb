require 'pry'
require 'google_drive_client'
require 'airbo_mixpanel_client'
class ReportRunner

  def initialize workbook_title=nil
    google_drive = GoogleDriveClient.new
    @workbook = set_workbook workbook_title
    @file = google_drive.spreadsheet_file_by_title workbook_title
  end

  def run workbook
    @data  = MixpanelReports::ActivitySessionByUserTypeAndBoard.new.pull
    @report_worksheet = @file.worksheet_by_title("Mixpanel Data")
  end

  def set_workbook workbook_title
    workbook_title || ENV['KPI_SPREADSHEET_NAME'] 
  end


  private

  def populate_sheet data

  end

  def populate_mixpanel_data
    data = mixpanel.activity_sessions_by_user_type_and_game @beg_date, @end_date
    process_mixpanel_all_activity_by_user_type data
  end

  def process_mixpanel_all_activity_by_user_type data
    curr_row =populate_header_row
    populate_rows data, curr_row + 1
    report_worksheet.save
  end

end



