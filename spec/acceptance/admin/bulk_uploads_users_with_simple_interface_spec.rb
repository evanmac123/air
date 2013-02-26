require 'acceptance/acceptance_helper'

feature 'Bulk uploads users with simple interface' do

  let(:admin) {an_admin}
  let(:demo) {admin.demo}
 
  def simulate_basic_census_file_upload
    MockS3.simulate_census_file_upload(Rails.root.join('spec/support/fixtures/small_simple_bulk_upload.csv'))  
  end

  def simulate_problematic_census_file_upload
    MockS3.simulate_census_file_upload(Rails.root.join('spec/support/fixtures/small_simple_bulk_upload_with_bad_lines.csv'))  
  end

  scenario 'has a form to upload file' do
    visit client_admin_simple_bulk_upload_path(as: admin)
   
    within "form[@enctype='multipart/form-data']" do
      find("input[type=file]").should be_present
      find("input[type=submit]").should be_present

      redirect_action_input = find("input[name=success_action_redirect]")
      redirect_action_input.value.should == client_admin_simple_bulk_upload_acceptance_path
    end
  end

  # Format for census file is:
  #
  # Employee ID (which we'll use for the unique ID)
  # Name
  # Email
  # Location name
  # Gender
  # DOB
  # Home ZIP code
  #
  # Only Employee ID and Name are mandatory

  scenario 'processes file after upload' do
    object_key = simulate_basic_census_file_upload

    demo.users.count.should == 1

    visit client_admin_simple_bulk_upload_acceptance_path(object_key: object_key, as: admin)

    crank_dj_clear

    demo.users.reload.count.should == 3 
    
    user1 = demo.users.find_by_employee_id('0001')
    user2 = demo.users.find_by_employee_id('0002')

    user1.name.should == 'John Smith'
    user1.email.should == 'john@example.com'
    user1.location.name.should == 'Cambridge'
    user1.gender.should == 'male'
    user1.date_of_birth.should == Date.parse('2012-01-01')
    user1.zip_code.should == '02139'

    user2.name.should == 'Jane Jones'
    user2.email.should == 'jane@example.com'
    user2.location.name.should == 'Boston'
    user2.gender.should == 'female'
    user2.date_of_birth.should == Date.parse('1977-09-10')
    user2.zip_code.should == '02116'
  end

  scenario 'shows report after processing a small file, with bad lines and duplicates noted' do
    object_key = simulate_problematic_census_file_upload

    visit client_admin_simple_bulk_upload_acceptance_path(object_key: object_key, as: admin)

    #crank_dj_clear
    pending
  end

  scenario 'sends email after processing a large file, with bad lines and duplicates noted'

  scenario "isn't available to client admins, only site admins (for now)" do
    visit client_admin_simple_bulk_upload_path(as: an_admin)
    should_be_on client_admin_simple_bulk_upload_path

    visit client_admin_simple_bulk_upload_path(as: a_client_admin)
    should_be_on activity_path
  end
end
