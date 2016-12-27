require 'acceptance/acceptance_helper'

feature 'Browses user lists' do
  let(:client_admin) { FactoryGirl.create(:client_admin) }
  before do
    FactoryGirl.create :tile, demo: client_admin.demo
  end


  def user_table_contents
    @user_table ||=page.all('.found-user').map(&:text)
  end

  def bust_user_table_cache
    @user_table = nil
  end

  def user_data_for users
    users.where(is_site_admin: false).map do |user|
      this_user_data(user)
    end
  end

  def this_user_data user
      [user.name, user.email, (user.claimed? ? "Yes" : "No"), nil].compact.join(' ')
  end


  it "should show everyone except site admin if asked" do
    5.times do |i|
      user = FactoryGirl.create(:user, name: "Dude #{i}", demo: client_admin.demo)
    end

    other_demo_guy = FactoryGirl.create(:user, name: "Johnny Otherdemo")
    other_demo_guy.demo.should_not == client_admin.demo
    site_admin_guy = FactoryGirl.create(:site_admin, name: "Site Dude", demo: client_admin.demo)

    non_site_admins = client_admin.demo.users.where(is_site_admin: false)

    visit client_admin_users_path(as: client_admin)
    click_link "Show everyone"

    user_data_for(non_site_admins).each do|data|
      expect(user_table_contents).to include(data)
    end

    expect(user_table_contents).to_not include(this_user_data(other_demo_guy))
    expect(user_table_contents).to_not include(this_user_data(site_admin_guy))
  end

  it "should paginate big result sets" do
    page_size = ClientAdmin::UsersController::PAGE_SIZE

    (page_size + 1).times do |i|
      FactoryGirl.create(:user, name: "Dude #{i}", demo: client_admin.demo)
    end

    users = client_admin.demo.users

    other_demo_guy = FactoryGirl.create(:user, name: "Johnny Otherdemo")
    expect(other_demo_guy.demo).to_not eq(client_admin.demo)

    visit client_admin_users_path(as: client_admin)
    click_link "Show everyone"

    users.where(is_client_admin: true).each do |admin|
      expect(page).to have_content(admin.email)
    end

    users.where(is_client_admin: false).alphabetical.limit(page_size).each do |user|
      expect(page).to have_content(user.email)
    end

    click_link "Next page"

    last_user = client_admin.demo.users.alphabetical.last

    expect(page).to have_content(last_user.email)
  end

  it "allows admin to invite user from the browse results page, assuming they have an email address", js:true do
    alfred = FactoryGirl.create(:user, name: "Alfred Jones", demo: client_admin.demo)
    alfred.should_not be_invited
    visit client_admin_users_path(show_everyone: true, as: client_admin)
   within("tr.found-user[data-user-id='#{alfred.id}']") do
      page.find(".send-invite-link").click
    end
    expect_content "OK, we've just sent #{alfred.name} an invitation."
  end

  it "should not present the option for an admin to try to invite a user without an email" do
    alfred = FactoryGirl.create(:user, name: "Alfred Jones", demo: client_admin.demo, email: '', official_email:"yada@yada.com")
    alfred.should_not be_invited
    visit client_admin_users_path(show_everyone: true, as: client_admin)
    page.all("a[href='#{client_admin_user_invitation_path(alfred)}']").should be_empty
  end
end
