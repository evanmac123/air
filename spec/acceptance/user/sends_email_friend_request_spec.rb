require 'acceptance/acceptance_helper'

feature "User tries to friend someone" do

  def first_name(user)
    user.name.split[0]
  end

  # NOTE: For debugging, use statement below to create a file like /tmp/email-123456789.txt
  # EmailSpec::EmailViewer.save_and_open_email(current_email)
  def deliver_and_open_email_for(recipient)
    crank_dj_clear
    open_email(recipient.email)
  end

  def accept_the_friendship
    # Use this method which finds/clicks a link based upon actual href
    # (In the HTML email the word "Accept" is actually in a <span> tag, not an <a href='xxx'> one
    click_email_link_matching /accept/
  end

  def see_new_connection
    click_email_link_matching /users/
  end

  # ========================================================================================

  let(:demo)    { FactoryGirl.create :demo }
  let(:user)    { FactoryGirl.create :user, :claimed, demo: demo, name: 'Joe User'   }
  let!(:friend) { FactoryGirl.create(:user, :claimed, demo: demo, name: 'Sue Friend').reload }

  before(:each) do
    bypass_modal_overlays(user)
  end

  background do
    signin_as(user, user.password)

    visit users_path
    fill_in 'search_string', with: 'Sue'
    click_button 'Find!'

    # NOTE: Can't use the statement below in place of the one above because the actual
    # button is hidden => results in a 'Capybara::Poltergeist::ObsoleteNode' error
    # click_button 'add_friend'

    page.find('div.follow-btn').click
    page.should have_content "OK, you'll be connected with Sue Friend, pending their acceptance"
  end

  scenario "A correct friend-request email is sent", js: true  do
    deliver_and_open_email_for(friend)

    current_email.should be_delivered_to(friend.email)
    current_email.should be_delivered_from(friend.reply_email_address)

    current_email.should have_subject("#{user.name} wants to be your friend on Airbo")

    current_email.should have_body_text /Hi #{first_name(friend)}/
    current_email.should have_body_text /#{user.name} has asked to be your connection on Airbo./
  end

  scenario "when the friend accepts the request, the user should get a notification email \
            see updated friend status, and actually be in a friendship", js: true  do

    page.should_not have_content "is now connected with #{first_name(friend)}"

    visit profile_page(user)
    page.should have_content "No connections yet"

    deliver_and_open_email_for(friend)
    accept_the_friendship

    visit profile_page(user)
    page.should have_content "is now connected with #{first_name(friend)}"

    user.should be_friends_with friend
    friend.should be_friends_with user

    deliver_and_open_email_for(user)

    current_email.should be_delivered_to(user.email)
    current_email.should be_delivered_from(user.reply_email_address)

    current_email.should have_subject("Message from Airbo")
    current_email.should have_body_text /#{friend.name} has approved your connection request./
  end

  scenario "when the friend accepts the request, the user should get a notification email \
            and should see his connection even if not logged in", js: true do
    deliver_and_open_email_for(friend)
    accept_the_friendship
    
    delete "/sign_out"

    deliver_and_open_email_for(user)
    see_new_connection
    current_path.should == user_path(friend)
    expect_content friend.name
    expect_content "Remove From Connections"
  end

  scenario "A friend should see the appropriate flash notification upon accepting the friendship", js: true  do
    deliver_and_open_email_for(friend)
    accept_the_friendship

    page.should have_content "OK, you are now connected with #{user.name}."
  end

  scenario "A friend should see the appropriate flash notification message upon accepting the friendship twice", js: true  do
    deliver_and_open_email_for(friend)
    accept_the_friendship
    accept_the_friendship

    page.should have_content "You are already connected with #{user.name}."
  end

  scenario "A friend should see a flash error message and not become friends \
            when he tries to process the friend request with an invalid token", js: true do
    deliver_and_open_email_for(friend)

    # Chop off the last character of the authenticity token
    link = links_in_email(current_email).find { |link| link =~ /accept/ }.chop
    visit request_uri(link)

    page.should have_content "Invalid authenticity token. Connection operation cancelled."

    user.should_not be_friends_with friend
    friend.should_not be_friends_with user
  end
end

