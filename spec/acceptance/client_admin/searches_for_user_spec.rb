require 'acceptance/acceptance_helper'

feature 'Searches for user by name' do
  let (:client_admin) { FactoryGirl.create :user, is_client_admin: true }
  let (:demo)         { client_admin.demo }

  let (:user_data) do
    [
      ["Franklin Pierce", "fpierce@example.com", "Boston", nil, true],
      ["Ben Franklin", "bfranklin@example.com", "Cambridge", 20.minutes.ago, true],
      ["Frank Sinatra", "fsinatra@example.com", "Dedham", nil, true],
      ["Frankie Valli", "fvalli@example.com", "Arlington", nil, false],
      ["Martha Stewart", "mstewart@example.com", "Boston", 3.weeks.ago, true]
    ]  
  end

  def create_user_from_tuple(user_tuple, demo)
    name, email, location_name, accepted_invitation_at, in_given_demo = user_tuple
    attributes = {
      name:                   name, 
      email:                  email, 
      location:               Location.find_by_name(location_name), 
      accepted_invitation_at: accepted_invitation_at}

    if in_given_demo
      attributes[:demo] = demo
    end

    FactoryGirl.create(:user, attributes)
  end

  def fill_in_name_search(name_substring)
    fill_in "name-substring", :with => name_substring
  end

  def wait_for_autocomplete
    within "#name-autocomplete-target" do
      wait_until(1) do
        while 1
          break if page.find('.ui-autocomplete').visible?
        end
      end
    end
  end

  def expect_user_autocomplete_entries(user_tuples)
    wait_for_autocomplete

    within "#name-autocomplete-target" do
      user_tuples.each {|user_tuple| expect_content user_tuple.first}
    end
  end

  def expect_no_user_autocomplete_entries(user_tuples)
    wait_for_autocomplete

    within "#name-autocomplete-target" do
      user_tuples.each {|user_tuple| expect_no_content user_tuple.first}
    end
  end

  def expect_autocomplete_link_to_create_user(user_name)
    wait_for_autocomplete

    within "#name-autocomplete-target" do
      expect_content %{No match for "#{user_name}". Click to add this user.}
      pending "See other pending remark regarding the shoddiness of Javascript testing"
    end
  end

  before do
    %w(Arlington Boston Cambridge Dedham Everett).each { |name| FactoryGirl.create(:location, name: name, demo: demo) }
    user_data.each { |user_tuple| create_user_from_tuple(user_tuple, demo) }
  end

  it "should show links for users with the given substring in the same demo as the given user, in alphabetical order", js: :webkit do
    visit client_admin_users_path(as: client_admin)

    fill_in_name_search "Frank"
    expect_user_autocomplete_entries(user_data[0,3])
    expect_no_user_autocomplete_entries(user_data[3,2])

    pending "\n\n\nClicking on the link to go to the edit page for that user works, but currently Poltergeist hangs up if you try it, and Capybara-webkit doesn't change location. You can switch this over to Selenium if you want to see for yourself. Check back here after the next capy-webkit update.\n\nSomeday we'll have a stable Javascript acceptance testing solution. Whether or not this happens before I retire is the question.\n\n"
    page.all('.ui-autocomplete a').select{|link| link.text == "Frank Sinatra"}.first.click
    should_be_on edit_client_admin_user_path(User.find_by_name('Frank Sinatra'))
  end

  it "should link to the add-user page when there are no matches", js: :webkit do
    visit client_admin_users_path(as: client_admin)

    fill_in_name_search "joey bananas"
    expect_no_user_autocomplete_entries(user_data)
    expect_autocomplete_link_to_create_user "Joey Bananas"
  end
end
