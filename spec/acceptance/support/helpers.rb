module HelperMethods
  def login_as(user, password)
    visit login_page
    fill_in "session[email]", :with => user.email
    fill_in "session[password]", :with => 'foobar'
    click_button "Let's play!"
  end

  def has_password(user, password)
    user.update_password(password, password)
  end

  def crank_dj(iterations=1)
    Delayed::Worker.new.work_off(iterations)
  end

  def current_email_address
    last_email_address || "dan@bigco.com"
  end

  def email_body
    current_email.default_part_body
  end

  def assert_suggestion_recorded(user_or_username, suggestion_text)
    user = user_or_username.kind_of?(User) ? user_or_username : User.find_by_name(user_or_username)
    Suggestion.where(:user_id => user.id, :value => suggestion_text).first.should_not be_nil
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
