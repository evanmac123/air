require 'acceptance/acceptance_helper'

feature 'Adds user' do
  let (:client_admin) { FactoryGirl.create(:client_admin) }
  let (:demo)         { client_admin.demo }

  def expect_add_message(name)
    expect_content "OK, we've added #{name}."
  end

  def expect_add_failed_message(error)
    expect_content "Sorry, we weren't able to add that user. #{error}"
  end

  def select_date_of_birth(month, day, year)
    select month, :from => "user[date_of_birth(2i)]"
    select day,   :from => "user[date_of_birth(3i)]"
    select year,  :from => "user[date_of_birth(1i)]"
  end

  def fill_in_user_information
    fill_in "Name",        :with => "Jehosaphat Emshwiller"
    fill_in "Email",       :with => "jemsh@example.com"
    fill_in "Employee ID", :with => "012345"
    fill_in "Zip code",    :with => "02139"

    select "Boston", :from => "Location code"
    select "other",  :from => "Gender"

    select_date_of_birth("April", "17", "1977")

    # And the characteristics
    click_link "More options"
    check 'Likes cats'
    fill_in "Date of last teeth cleaning", :with => "Jan 1, 2012"
    fill_in "Remaining teeth", :with => "27"
    fill_in "Lunchtime", :with => "March 12, 2013, 2:30 PM"
    select "George", :from => "Favorite Beatle"
  end

  def create_characteristics(demo)
    @boolean_characteristic = FactoryGirl.create :characteristic, :boolean, name: "Likes cats", demo_id: demo.id
    @date_characteristic = FactoryGirl.create :characteristic, :date, name: "Date of last teeth cleaning", demo_id: demo.id
    @number_characteristic = FactoryGirl.create :characteristic, :number, name: "Remaining teeth", demo_id: demo.id
    @time_characteristic = FactoryGirl.create :characteristic, :time, name: "Lunchtime", demo_id: demo.id
    @discrete_characteristic = FactoryGirl.create :characteristic, :discrete, name: "Favorite Beatle", allowed_values: %w(John Paul George Ringo), demo_id: demo.id
  end

  def create_locations(demo)
    %w(Atlanta Boston Cleveland Detroit).each {|name| demo.locations.create!(name: name)}
  end

  before do
    create_characteristics(demo)
    create_locations(demo)
    visit client_admin_users_path(as: client_admin)
  end

  it "should work when all entered data is valid", js: true do
    demo.users.count.should == 1 # just the admin

    fill_in_user_information
    click_button "Add user"

    should_be_on client_admin_users_path

    demo.users.reload.count.should == 2
    new_user = demo.users.order("created_at DESC").first
    new_user.name.should == "Jehosaphat Emshwiller"
    new_user.email.should == "jemsh@example.com"
    new_user.employee_id.should == "012345"
    new_user.zip_code.should == "02139"
    new_user.claim_code.should be_present
    new_user.date_of_birth.should == Date.parse("1977-04-17")
    new_user.gender.should == "other"

    new_user.characteristics[@boolean_characteristic.id].should == true
    new_user.characteristics[@discrete_characteristic.id].should == 'George'
    new_user.characteristics[@date_characteristic.id].should == Date.parse('2012-01-01')
    new_user.characteristics[@time_characteristic.id].should == Time.parse("2013-03-12 14:30")
    new_user.characteristics[@number_characteristic.id].should == 27

    expect_add_message "Jehosaphat Emshwiller"
  end

  it "should show meaningful errors when entered data is invalid" do
    click_button "Add user"
    should_be_on client_admin_users_path

    demo.users.reload.count.should == 1
    expect_add_failed_message "Please enter a first and last name"
  end
end
