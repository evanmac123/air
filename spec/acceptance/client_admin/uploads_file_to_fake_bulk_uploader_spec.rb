require 'acceptance/acceptance_helper'

feature 'Uploads file to fake bulk uploader' do
  include CarrierWaveDirect::Test::CapybaraHelpers

  before(:all) do
    Fog.mock!

    connection = ::Fog::Storage.new(
      :aws_access_key_id      => 'fake_access_key_id',
      :aws_secret_access_key  => 'fake_secret_access_key',
      :provider               => 'AWS'
    )

    connection.directories.create(:key => 'foobars')
  end

  after(:all) do
    Fog.unmock!
  end

  before do
    @client_admin = a_client_admin
  end

  it "has a reasonable message for the user"

  it "notifies us by email" do
    visit new_client_admin_bulk_upload_path(as: @client_admin)
    attach_file_for_direct_upload('spec/support/fixtures/arbitrary_csv.csv')
    upload_directly(BulkUserUploader.new, "Upload to S3")

    crank_dj_clear
    open_email(BulkUploadNotificationMailer::ADDRESS_TO_NOTIFY)

    current_email.body.should match(%r!https://s3.amazonaws.com/#{BULK_UPLOADER_BUCKET}/uploads/[0123456789abcdef-]{36}/arbitrary_csv.csv!)
    current_email.body.should contain(@client_admin.name)
    current_email.body.should contain(@client_admin.email)
    current_email.body.should contain(@client_admin.demo.name)
    current_email.body.should contain(@client_admin.demo_id)
  end
end
