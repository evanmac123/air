require 'acceptance/acceptance_helper'

feature 'Browses user lists' do
  let(:client_admin) { FactoryGirl.create(:client_admin) }

  def expect_browse_row(user, sense=true)
    within '#search-results-table' do
      expected_text = [user.name, user.email, user.location.try(:name), (user.claimed? ? "Yes" : "No"), "Send"].compact.join(' ')
      page.all('.found-user').any? { |row| row.text == expected_text }.should == sense
    end
  end

  def expect_no_browse_row(user)
    expect_browse_row(user, false)
  end

  it "should show everyone if asked" do
    5.times { |i| FactoryGirl.create(:user, :with_location, name: "Dude #{i}", demo: client_admin.demo) }
    other_demo_guy = FactoryGirl.create(:user, :with_location, name: "Johnny Otherdemo")
    other_demo_guy.demo.should_not == client_admin.demo

    visit client_admin_users_path(as: client_admin)
    click_link "Show everyone"

    client_admin.demo.users.each {|user| expect_browse_row(user)}
    expect_no_browse_row(other_demo_guy)
    expect_content "Showing results for everyone"
  end

  it "should paginate big result sets" do
    page_size = ClientAdmin::UsersController::PAGE_SIZE

    client_admin.update_attributes(name: "Zzzzzzzzz") # hack to make sure admin appears at the end of the list
    (2 * page_size).times { |i| FactoryGirl.create(:user, :with_location, name: "Dude #{i}", demo: client_admin.demo) }
    other_demo_guy = FactoryGirl.create(:user, :with_location, name: "Johnny Otherdemo")
    other_demo_guy.demo.should_not == client_admin.demo

    visit client_admin_users_path(as: client_admin)
    click_link "Show everyone"

    first_page_users = client_admin.demo.users.alphabetical.limit(page_size)
    second_page_users = client_admin.demo.users.alphabetical.limit(page_size).offset(page_size)

    first_page_users.each {|user| expect_browse_row(user)}
    second_page_users.each {|user| expect_no_browse_row(user)}
    expect_no_browse_row(client_admin)

    expect_no_content "Previous page"
    click_link "Next page"

    first_page_users.each {|user| expect_no_browse_row(user)}
    second_page_users.each {|user| expect_browse_row(user)}
    expect_no_browse_row(client_admin)

    expect_content "Previous page"
    click_link "Next page"

    first_page_users.each {|user| expect_no_browse_row(user)}
    second_page_users.each {|user| expect_no_browse_row(user)}
    expect_browse_row(client_admin)

    expect_content "Previous page"
    expect_no_content "Next page"

    click_link "Previous page"

    first_page_users.each {|user| expect_no_browse_row(user)}
    second_page_users.each {|user| expect_browse_row(user)}
    expect_no_browse_row(client_admin)

    click_link "Previous page"
    first_page_users.each {|user| expect_browse_row(user)}
    second_page_users.each {|user| expect_no_browse_row(user)}
    expect_no_browse_row(client_admin)
  end

  it "allows admin to invite user from the browse results page" do
    alfred = FactoryGirl.create(:user, :with_location, name: "Alfred Jones", demo: client_admin.demo)
    alfred.should_not be_invited
    visit client_admin_users_path(show_everyone: true, as: client_admin)
    within("tr:nth-of-type(2)") { click_link "Send" }
    alfred.reload.should be_invited
    expect_content "OK, we've just sent #{alfred.name} an invitation."
  end
end
