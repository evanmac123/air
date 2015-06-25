require 'acceptance/acceptance_helper'

feature 'Browses user lists' do
  let(:client_admin) { FactoryGirl.create(:client_admin) }
  before do
    FactoryGirl.create :tile, demo: client_admin.demo
  end

  def expect_browse_row(user, sense=true)
    within '#search-results-table' do
      expected_text = [user.name, user.email, (user.claimed? ? "Yes" : "No"), (user.invitable? ? "Send" : nil)].compact.join(' ')
      page.all('.found-user').any? { |row| row.text == expected_text }.should == sense
    end
  end

  def expect_no_browse_row(user)
    expect_browse_row(user, false)
  end

  it "should show everyone except site admin if asked" do
    5.times do |i| 
      user = FactoryGirl.create(:user, name: "Dude #{i}", demo: client_admin.demo)
    end

    other_demo_guy = FactoryGirl.create(:user, name: "Johnny Otherdemo")
    other_demo_guy.demo.should_not == client_admin.demo

    site_admin_guy = FactoryGirl.create(:site_admin, name: "Site Dude", demo: client_admin.demo)
    visit client_admin_users_path(as: client_admin)
    click_link "Show everyone"

    client_admin.demo.users.where(is_site_admin: false).each {|user| expect_browse_row(user)}
    expect_no_browse_row(other_demo_guy)
    expect_no_browse_row(site_admin_guy)
    expect_content "Showing results for everyone"
  end

  # NOTE: This test takes about 2 1/2 minutes to run (on my old machine, at least, RIP)
  # Or even longer, especially if you're in a hurry.
  it "should paginate big result sets" do
    puts "STARTING A SLOW TEST, GET COMFORTABLE"
    puts "STARTING AT #{Time.now.to_s}"
    page_size = ClientAdmin::UsersController::PAGE_SIZE

    client_admin.update_attributes(name: "Zzzzzzzzz") # hack to make sure admin appears at the end of the list
    (2 * page_size).times do |i| 
      user = FactoryGirl.create(:user, name: "Dude #{i}", demo: client_admin.demo)
    end   

    other_demo_guy = FactoryGirl.create(:user, name: "Johnny Otherdemo")
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
    puts "DONE AT #{Time.now.to_s}"
  end

  it "allows admin to invite user from the browse results page, assuming they have an email address" do
    alfred = FactoryGirl.create(:user, name: "Alfred Jones", demo: client_admin.demo)
    alfred.should_not be_invited
    visit client_admin_users_path(show_everyone: true, as: client_admin)
    within("tr:nth-of-type(2)") { click_link "Send" }
    alfred.reload.should be_invited
    expect_content "OK, we've just sent #{alfred.name} an invitation."
  end

  it "should not present the option for an admin to try to invite a user without an email" do
    alfred = FactoryGirl.create(:user, name: "Alfred Jones", demo: client_admin.demo, email: '')
    alfred.should_not be_invited
    visit client_admin_users_path(show_everyone: true, as: client_admin)

    page.all("a[href='#{client_admin_user_invitation_path(alfred)}']").should be_empty
  end
end
