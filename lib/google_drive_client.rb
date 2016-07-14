require 'google/api_client'

class GoogleDriveClient
  APP_NAME="Airbo"
  APP_VERSION="2.0"
  SCOPE= ["https://www.googleapis.com/auth/drive", "https://spreadsheets.google.com/feeds/"] 

  attr_reader :session

  def initialize
   @session = auth_to_google_drive
  end

  def spreadsheet_file_by_title title
     session.spreadsheet_by_title(title)
  end

  private


  def auth_to_google_drive
    key = OpenSSL::PKey::RSA.new ENV['GOOGLE_API_PRIVATE_KEY'], 'notasecret'
    client = Google::APIClient.new(application_name: APP_NAME, application_version: 'APP_VERSION')
    asserter = Google::APIClient::JWTAsserter.new( ENV["GOOGLE_API_CLIENT_EMAIL"], SCOPE,key)
    client.authorization = asserter.authorize("herby@airbo.com")
    GoogleDrive.login_with_oauth(client.authorization.access_token)
  end 

end
