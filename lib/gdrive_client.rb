require 'google/api_client'
require 'pry'

class GdriveClient
  APP_NAME="Airbo"
  APP_VERSION="2.0"
  SCOPE= ["https://www.googleapis.com/auth/drive", "https://spreadsheets.google.com/feeds/"] 
  FREE_HRM_ROW_INDEX = 8 
  
  attr_accessor :google_api_session, :mixpanel_client, :kpi_worksheet, :mixpanel_worksheet

   def initialize
     auth_to_google_drive
     auth_to_mixpanel
     @beg_date = Date.today.beginning_of_week(:sunday).prev_week(:sunday).at_midnight
     @end_date = @beg_date.end_of_week(:sunday).end_of_day
   end

   def run_report 
     file = google_api_session.spreadsheet_by_title(ENV['KPI_SPREADSHEET_NAME'])
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
     #mixpanel_free_hrm_activity
     mixpanel_all_activity_by_user_type
     #update_free_hrms
   end

   def update_free_hrms
     all_paid =  (paid_client_admins_by_bm | paid_client_admins_by_user_type).uniq.count
     kpi_worksheet[FREE_HRM_ROW_INDEX,@new_col_index] = all_client_admins - all_paid
     kpi_worksheet.save
   end

   #-----------------------------------------
   # Mixpanle API Request
   #------------------------------------------

   def mixpanel_free_hrm_activity
     result = mixpanel_client.request(
       'segmentation',
       event:     'Activity Session - New',
       from_date: '2015-10-12',
       to_date:   '2015-10-18',
       type:      'unique',
       unit:      'week',
       on:        'properties["board_type"]',
       where:     '"Free" == properties["'+ 'board_type' +'"] and "client admin" ==properties["'+ 'user_type' + '"]'
     )

   end

   def mixpanel_all_activity_by_user_type
     result = mixpanel_client.request(
       'segmentation/multiseg',
       event:     'Activity Session - New',
       from_date: '2015-10-12',
       to_date:   '2015-10-18',
       type:      'unique',
       unit:      'week',
       inner:    'properties["user_type"]',
       outer:     'properties["game"]',
     )

     process_mixpanel_all_activity_by_user_type result["data"]["values"]
     mixpanel_worksheet.save
   end

   #-----------------------------------------
   #  Direct DB Queries
   #------------------------------------------

 
   def all_client_admins
     @all_client_admins ||=User.where("is_client_admin is true and is_test_user is null and created_at > ?", '2010/01/01 00:00').count
   end

   def paid_client_admins_by_bm
     @paid_client_admins_by_bm ||=BoardMembership.joins(:demo).where("board_memberships.is_client_admin is true and demos.is_paid is true").pluck(:user_id).uniq
   end

   def paid_client_admins_by_user_type
     @paid_client_admins_by_user_type ||= User.joins(:board_memberships).joins(:demos).where("users.is_client_admin is true and demos.is_paid is true").pluck("users.id").uniq
   end

   #-----------------------------------------
   # Process mixpanel date
   #------------------------------------------

    def process_mixpanel_all_activity_by_user_type data
      export=[]
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


   #-----------------------------------------
   #  Authentication 
   #------------------------------------------

   def auth_to_mixpanel
     @mixpanel_client ||= Mixpanel::Client.new( api_key: ENV['MIXPANEL_API_KEY'],  api_secret: ENV['MIXPANEL_API_SECRET'])
   end
 
   def auth_to_google_drive
     key = OpenSSL::PKey::RSA.new ENV['GOOGLE_API_PRIVATE_KEY'], 'notasecret'
     client = Google::APIClient.new(application_name: APP_NAME, application_version: 'APP_VERSION')
     asserter = Google::APIClient::JWTAsserter.new( ENV["GOOGLE_API_CLIENT_EMAIL"], SCOPE,key)
     client.authorization = asserter.authorize("herby@airbo.com")
     @google_api_session = GoogleDrive.login_with_oauth(client.authorization.access_token)
   end 



end
