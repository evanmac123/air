require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Email is sent when a user tries to friend someone" do

  let(:demo)   { FactoryGirl.create :demo }
  let(:user)   { FactoryGirl.create :user, :claimed, demo: demo, name: 'Joe User',   password: 'joeuser' }

  before(:each) do
    # NOTE: Need these guys to get rid of fancybox screens for talking-chicken tutorial and inviting people to join the game
    #       If don't get rid of these screens => can't click on any links because they are "covered"
    User.any_instance.stubs(:create_tutorial_if_none_yet)
    user.update_attribute :session_count, 10

    # NOTE: Can't do the statement below because the friend never gets created, even though there's a '!' on the end of 'let'
    # let!(:friend) { FactoryGirl.create :user, :claimed, demo: demo, name: 'Sue Friend' }
    @friend = FactoryGirl.create :user, :claimed, demo: demo, name: 'Sue Friend', email: 'sue@friend.com'
  end

  background do
    signin_as(user, user.password)

    click_link 'Directory'
    fill_in 'search_string', with: 'Sue'
    click_button 'Find!'

    # NOTE: Can't do the statement below because the button is hidden, which results in a 'Capybara::Poltergeist::ObsoleteNode' error
    # click_button 'add_friend'
    page.find('div.follow-btn').click
  end

  scenario "User accepts the friend request", js: true do
    page.should have_content "OK, you'll be friends with Sue Friend, pending their acceptance"
    crank_dj_clear

    open_email(@friend.email)
    EmailSpec::EmailViewer::save_and_open_email(current_email)

    current_email.should have_subject('Joe User wants to be your friend on H Engage')
    current_email.should be_delivered_from(@friend.reply_email_address)
    current_email.default_part_body.to_s.should include('Hi Sue')

    visit_in_email('Accept')
  end

  #scenario "User rejects the friend request", js: true do
  #end
end

  #  EmailInfoRequest.stubs(:"create!")
  #
  #  @phone = "(332) 334-3322"
  #  @name = "James Hennessey IX"
  #  @email = "somthingfornothing@james.com"
  #  @comment = "You guys kick serious a$$"
  #  visit marketing_page
  #  click_link "Request a Demo"
  #
  #  fill_in "contact_name", :with => @name
  #  fill_in "contact_email", :with => @email
  #  fill_in "contact_phone", :with => @phone
  #  fill_in "contact_comment", :with => @comment
  #  click_button "contact-submit"
  #
  #  page.should have_content "Thanks! We'll be in touch"
  #  crank_dj_clear
  #
  #  EmailInfoRequest.should have_received(:"create!").with(email: @email, name: @name, phone: @phone, comment: @comment)
  #end
