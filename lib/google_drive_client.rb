require 'google/api_client'
require 'pry'

class GoogledriveClient
  APP_NAME="Airbo"
  APP_VERSION="2.0"
  SCOPE= ["https://www.googleapis.com/auth/drive", "https://spreadsheets.google.com/feeds/"] 

  def initialize
    auth_to_google_drive
  end

  def spreadsheet_by_title title
     file = session.spreadsheet_by_title()
  end

  private

  def session
    @session
  end

  def auth_to_google_drive
    key = OpenSSL::PKey::RSA.new ENV['GOOGLE_API_PRIVATE_KEY'], 'notasecret'
    client = Google::APIClient.new(application_name: APP_NAME, application_version: 'APP_VERSION')
    asserter = Google::APIClient::JWTAsserter.new( ENV["GOOGLE_API_CLIENT_EMAIL"], SCOPE,key)
    client.authorization = asserter.authorize("herby@airbo.com")
    @session = GoogleDrive.login_with_oauth(client.authorization.access_token)
  end 

end
