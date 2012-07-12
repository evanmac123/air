module SteakHelperMethods
  def fill_in_signin_fields(user, password)
    visit signin_page
    fill_in "session[email]", :with => user.email
    fill_in "session[password]", :with => password
  end

  def signin_as(user, password)
    fill_in_signin_fields(user, password)
    click_button "Let's play!"
  end

  def signin_as_admin
    admin = FactoryGirl.create :user, :is_site_admin => true
    has_password(admin, 'foobar')
    signin_as(admin, 'foobar')
  end

  def has_password(user, password)
    user.update_password(password)
  end

  def crank_dj(iterations=1)
    Delayed::Worker.new.work_off(iterations)
  end

  def crank_off_dj
    while(Delayed::Job.where("run_at <= ?", Time.now).count > 0)
      crank_dj(10)
    end
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
    check "user_terms_and_conditions"
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

  def page_text
    page.text.gsub(/\s+/, ' ')
  end

  def expect_content(expected_content)
    page_text.should include(expected_content)
  end

  def expect_no_content(unexpected_content)
    page_text.should_not include(unexpected_content)
  end

  def find_select_element(select_identifier)
    page.find(:xpath, XPath::HTML.select(select_identifier).to_xpath)  
  end

  def expect_selected(select_identifier, expected_value)
    select = find_select_element(select_identifier)
    option_expected_to_be_selected = select.find %{option[@value="#{expected_value}"]}
    option_expected_to_be_selected['selected'].should be_present
  end

  def expect_no_option_selected(select_identifier)
    select = find_select_element(select_identifier)
    select.all("option[@select]").should be_empty
  end

  def find_select_element(select_identifier)
    page.find(:xpath, XPath::HTML.select(select_identifier).to_xpath)  
  end

  def find_input_element(input_identifier)
    page.find(:xpath, XPath::HTML.field(input_identifier).to_xpath)
  end

  def expect_selected(select_identifier, expected_value)
    select = find_select_element(select_identifier)
    option_expected_to_be_selected = select.find %{option[@value="#{expected_value}"]}
    option_expected_to_be_selected['selected'].should be_present
  end

  def expect_no_option_selected(select_identifier)
    select = find_select_element(select_identifier)
    select.all("option[@select]").should be_empty
  end

  def expect_value(input_identifier, expected_value)
    input = find_input_element(input_identifier)
    input.value.should == expected_value
  end

  def expect_checked(checkbox_identifier)
    checkbox = find_input_element(checkbox_identifier)
    checkbox.value.to_i.should == 1
  end

  def expect_gold_coin_header(expected_coin_count)
    expect_content "#{expected_coin_count} gold coins"
  end
end
