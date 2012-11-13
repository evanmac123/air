require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User tries to friend someone" do

  def first_name(user)
    user.name.split[0]
  end

  def deliver_and_open_email(recipient)
    crank_dj_clear
    open_email(recipient.email)
  end

  let(:demo) { FactoryGirl.create :demo }
  let(:user) { FactoryGirl.create :user, :claimed, demo: demo, name: 'Joe User' }

  before(:each) do
    # NOTE: Need these guys to get rid of overlay screens for talking-chicken tutorial and inviting people
    # to join the game. If don't get rid of these screens => can't click on any links because they are "covered".
    User.any_instance.stubs(:create_tutorial_if_none_yet) # Uses 'fancybox' css selectors
    user.update_attribute :session_count, 10              # Uses 'facebox'  css selectors

    # NOTE: Can't use the 'let!' statement below with the other 'let's (above) because the
    # friend never gets created, even though there's a '!' on the end of 'let'... wtf!
    # let!(:friend) { FactoryGirl.create :user, :claimed, demo: demo, name: 'Sue Friend' }

    @friend = FactoryGirl.create :user, :claimed, demo: demo, name: 'Sue Friend', email: 'sue@friend.com'
  end

  background do
    signin_as(user, user.password)

    click_link 'Directory'
    fill_in 'search_string', with: 'Sue'
    click_button 'Find!'

    # NOTE: Can't use the statement below in place of the one above because the actual
    # button is hidden => results in a 'Capybara::Poltergeist::ObsoleteNode' error
    # click_button 'add_friend'

    page.find('div.follow-btn').click
  end

  scenario "Notice is displayed on page and friend-request email is sent", js: true  do
    page.should have_content "OK, you'll be friends with Sue Friend, pending their acceptance"

    deliver_and_open_email @friend

    # NOTE: For debugging, creates a file like /tmp/email-123456789.txt
    #EmailSpec::EmailViewer.save_and_open_email(current_email)

    current_email.should be_delivered_to(@friend.email)
    current_email.should be_delivered_from(@friend.reply_email_address)

    current_email.should have_subject("#{user.name} wants to be your friend on H Engage")

    current_email.should have_body_text /Hi #{first_name(@friend)}/
    current_email.should have_body_text /#{user.name} has asked to be your friend on H Engage./
  end

  scenario "User accepts the friend request; notices are displayed; notification email is sent", js: true  do
    page.should_not have_content "is now friends with #{first_name(@friend)}"

    visit profile_page(user)
    page.should have_content "No friends yet"

    deliver_and_open_email @friend

    # Use this method which finds/clicks a link based upon actual href
    # (In the HTML email the word "Accept" is actually in a <span> tag, not an <a href='xxx'> one
    click_email_link_matching /accept/

    page.should have_content "OK, you are now friends with #{user.name}."

    visit profile_page(user)
    page.should have_content "is now friends with #{first_name(@friend)}"

    user.should be_friends_with @friend
    @friend.should be_friends_with user

    crank_dj_clear
    open_email(user.email)

    current_email.should be_delivered_to(user.email)
    current_email.should be_delivered_from(user.reply_email_address)

    current_email.should have_subject("Message from H Engage")
    current_email.should have_body_text /#{@friend.name} has approved your friendship request./
  end

  scenario "User tries to force processing of the friend request with an invalid token", js: true do
    deliver_and_open_email @friend

    # Chop off the last character of the authenticity token
    link = links_in_email(current_email).find { |link| link =~ /accept/ }.chop
    visit request_uri(link)

    page.should have_content "Invalid authenticity token. Friendship operation cancelled."

    user.should_not be_friends_with @friend
    @friend.should_not be_friends_with user
  end
end

