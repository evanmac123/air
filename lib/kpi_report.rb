require 'pry'
class KpiReport 

  FREE_HRM_ROW_INDEX = 8 


  attr_accessor :g_drive_client, :mixpanel_client, :kpi_worksheet, :mixpanel_worksheet

   def initialize
     @g_drive_client = GoogleDriveClient.new
     @mixpanel_client = AirboMixpanelClient.new
     @beg_date = Date.today.beginning_of_week(:sunday).prev_week(:sunday).at_midnight
     @end_date = @beg_date.end_of_week(:sunday).end_of_day
   end

   def run_report 
     file = g_drive_client.spreadsheet_by_title ENV['KPI_SPREADSHEET_NAME']
     @kpi_worksheet = file.worksheet_by_title("KPIs")
     @mixpanel_worksheet = file.worksheet_by_title("Mixpanel Data")
     setup_kpi_worksheet
     populate_data
   end



   private

   #-----------------------------------------
   # Populdate Data
   #------------------------------------------

   def populate_data
     data = mixpanel_client.activity_sessions_by_user_type_and_game
     process_mixpanel_all_activity_by_user_type data
     mixpanel_worksheet.save
   end

 

    def process_mixpanel_all_activity_by_user_type data
      ["Board", "Client Admin","User","Guest"].each_with_index do|header,idx|
        mixpanel_worksheet[1,idx+1] = header
      end

      row_idx =2

      data.each_with_index do |(board,types), idx| 
        row = []
        mixpanel_worksheet[row_idx, 1]=board
        mixpanel_worksheet[row_idx, 2]=data[board]["client admin"].values.first
        mixpanel_worksheet[row_idx, 3]=data[board]["ordinary user"].values.first
        mixpanel_worksheet[row_idx, 4]=data[board]["guest"].values.first
       row_idx+=1
      end
      mixpanel_worksheet.save
    end


   #-----------------------------------------
   # Prepare sheet for data
   #------------------------------------------


   def setup_kpi_worksheet
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



end
