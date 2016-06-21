require 'pry'
require 'google_drive_client'
require 'airbo_mixpanel_client'
class KpiReport 

  FREE_HRM_ROW_INDEX = 8 


  attr_reader :g_drive_client, :mixpanel_client, :kpi_worksheet, :mixpanel_worksheet, :file

  def initialize
    @g_drive_client = GoogleDriveClient.new
    @mixpanel_client = AirboMixpanelClient.new
    @beg_date = Date.today.beginning_of_week(:sunday).prev_week(:sunday).at_midnight
    @end_date = @beg_date.end_of_week(:sunday).end_of_day
  end

  def run_report 
    @file = g_drive_client.spreadsheet_by_title ENV['KPI_SPREADSHEET_NAME']
    populate_mixpanel_data
  end


  private

  def populate_mixpanel_data

    @mixpanel_worksheet = file.worksheet_by_title("Mixpanel Data")
    data = mixpanel_client.activity_sessions_by_user_type_and_game @beg_date, @end_date
    process_mixpanel_all_activity_by_user_type data
    mixpanel_worksheet.save
  end

  def process_mixpanel_all_activity_by_user_type data
    populate_header_row
    populate_rows data
    mixpanel_worksheet.save
  end

  def populate_header_row
    ["Board", "Client Admin","User","Guest"].each_with_index do|header,idx|
      mixpanel_worksheet[1,idx+1] = header
    end
  end

  def populate_rows data
    row_idx =2
    data.each_with_index do |(board,types), idx| 
      mixpanel_worksheet[row_idx, 1]=board
      ["client admin", "ordinary user", "guest"].each_with_index do |subkey, col_idx|
        mixpanel_worksheet[row_idx, col_idx + 2]=data.fetch(board, {}).fetch(subkey, {}).values.first
      end
      row_idx+=1
    end
  end


  #-----------------------------------------
  # Prepare KPI sheet for data
  #------------------------------------------


  def setup_kpi_worksheet
    @kpi_worksheet = file.worksheet_by_title("KPIs")
    add_column
    duplicate_last_column
  end

  def duplicate_last_column
    (1..kpi_worksheet.num_rows).each do |row|
      kpi_worksheet[row,@new_col_index]= kpi_worksheet.input_value(row, @last_col_index)
    end
    kpi_worksheet.save
  end


  def add_column
    @last_col_index = kpi_worksheet.num_cols
    @new_col_index = @last_col_index +1
    kpi_worksheet.max_cols =@new_col_index
    kpi_worksheet.save
  end

end



