module SteakHelperMethods
  def fill_in_signin_fields(user, password)
    visit signin_page
    fill_in "session[email]", :with => user.email
    fill_in "session[password]", :with => 'foobar'
  end

  def signin_as(user, password)
    fill_in_signin_fields(user, password)
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

  def expect_suggestion_recorded(user_or_username, suggestion_text)
    user = user_or_username.kind_of?(User) ? user_or_username : User.find_by_name(user_or_username)
    Suggestion.where(:user_id => user.id, :value => suggestion_text).first.should_not be_nil
  end

  def fill_in_required_invitation_fields
    fill_in "Enter your name", :with => "Jack Russell"
    fill_in "Choose a username", :with => "jrussell"
    fill_in "Choose a password", :with => "foobar"
    fill_in "And confirm that password", :with => "foobar"
  end

  def expect_avatar48(expected_filename)
    within('.avatar48') do 
      avatar = page.find(:css, 'img')
      avatar['src'].should =~ /#{expected_filename}$/
    end
  end

  def expect_inline_style(css_selector, style_key, expected_value)
    element = find(:css, css_selector)
    style = element['style']
    style.should_not be_nil

    styles = style.split(/\s*\;\s*/)

    style_sought = styles.detect{|style| style =~ /^#{style_key}\s*:\s*(.*)$/}
    style_sought.should_not be_nil
    $1.should == expected_value
  end
end
