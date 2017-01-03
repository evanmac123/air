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
    FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: @client_admin.demo) # unlock the users page
  end

  def expect_total_users_display(count)
    expect(page).to have_content("Activated users #{count}")
  end

  def template_url
    "https://s3.amazonaws.com/airbo_downloadable_templates/Sample_Eligibility_File_name_and_email.csv"
  end

  def simulate_upload
    attach_file_for_direct_upload('spec/support/fixtures/arbitrary_csv.csv')
    upload_directly(BulkUserUploader.new, "Upload user file")
  end

  def upload_in_progress_message
    "Upload in progress. You can leave this page and we'll email you when it's complete."
  end

  def last_loaded_message
    date_string = Time.zone.now.strftime("%B %e, %Y")
    "Last added users on #{date_string}"
  end

  it "notifies us by email" do
    visit client_admin_users_path(as: @client_admin)
    simulate_upload

    crank_dj_clear
    open_email(BulkUploadNotificationMailer::ADDRESS_TO_NOTIFY)

    expect(current_email.body).to match(%r!https://s3.amazonaws.com/#{BULK_UPLOADER_BUCKET}/uploads/[0123456789abcdef-]{36}/arbitrary_csv.csv!)
    expect(current_email.body).to contain(@client_admin.name)
    expect(current_email.body).to contain(@client_admin.email)
    expect(current_email.body).to contain(@client_admin.demo.name)
    expect(current_email.body).to contain(@client_admin.demo_id)
  end

  it "has a count of the number of users" do
    expect(@client_admin.demo.users.claimed).to be_empty

    visit client_admin_users_path(as: @client_admin)
    expect_total_users_display 0

    3.times do
      user = FactoryGirl.create(:user, :claimed)
      user.add_board(@client_admin.demo)
    end

    2.times do
      user = FactoryGirl.create(:user, :unclaimed)
      user.add_board(@client_admin.demo)
    end

    expect(@client_admin.demo.users.claimed.size).to eq(3)
    visit client_admin_users_path(as: @client_admin)
    expect_total_users_display 3
  end

  it "has a downloadable template" do
    visit client_admin_users_path(as: @client_admin)
    expect(page.first("a[href=\"#{template_url}\"]")).to be_present
  end

  it "has a reasonable message for the user" do
    visit client_admin_users_path(as: @client_admin)
    expect(page).to have_no_content(upload_in_progress_message)

    simulate_upload
    expect(page).to have_content(upload_in_progress_message)
  end

  it "updates the users_last_loaded date" do
    Timecop.freeze
    begin
      visit client_admin_users_path(as: @client_admin)
      expect(page).to have_no_content(last_loaded_message)

      simulate_upload
      expect(page).to have_content(last_loaded_message)
    ensure
      Timecop.return
    end
  end
end
