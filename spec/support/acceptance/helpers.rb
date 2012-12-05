module SteakHelperMethods
  def fill_in_signin_fields(user, password)
    visit signin_page
    fill_in "session[email]", :with => user.email
    fill_in "session[password]", :with => password
  end

  def signin_as(user, password)
    #Note: In controller specs you can just use Clearance's sign_in_as(user) method instead
    # Or even try Clearance's sign_in() -- it creates a user for you
    fill_in_signin_fields(user, password)
    click_button "Let's play!"
  end

  def signin_as_admin
    # For some reason I'm getting an 
    # ActiveRecord::AssociationTypeMismatch:
    #        Demo(#69995131463640) expected, got Demo(#69995116100040)
    # error if I call this method from guard/spork and then 
    # make a call to FactoryGirl.create(:tile, demo: @some_demo_ive_already_created)
    # Works fine from rspec.
    # So in guard/spork I'm just making my call to signin_as_admin AFTER creating my 
    # other factories. (Cross fingers)
    admin = FactoryGirl.create :user, :is_site_admin => true
    has_password(admin, 'foobar')
    signin_as(admin, 'foobar')
    admin
  end

  def signin_as_client_admin
    admin = FactoryGirl.create :user, :is_client_admin => true
    has_password(admin, 'foobar')
    signin_as(admin, 'foobar')
    admin
  end

  def clearance_signin_as_admin
    admin = FactoryGirl.create :user, :is_site_admin => true
    sign_in_as(admin) # This is clearance's built in method
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
    fill_in "Choose a password", :with => "foobar"
    fill_in "Confirm password", :with => "foobar"
    check "user_terms_and_conditions"
  end

  def expect_avatar_in_masthead(expected_filename)
    within('.avatar48') do 
      avatar = page.find(:css, 'img')
      avatar_url = avatar['src'].gsub(/\?.*$/, '') # Chop off query params
      avatar_url.should =~ /#{expected_filename}$/
    end
  end

  def expect_default_avatar_in_masthead
    expect_avatar_in_masthead('missing.png')
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

  def find_select_element(select_identifier)
    page.find(:xpath, XPath::HTML.select(select_identifier).to_xpath)  
  end

  def find_input_element(input_identifier)
    page.find(:xpath, XPath::HTML.field(input_identifier).to_xpath)
  end

  def expect_selected(expected_value, select_identifier = nil)
    option_context = select_identifier ? find_select_element(select_identifier) : page
    option_expected_to_be_selected = option_context.find %{option[@value="#{expected_value}"]}
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

  def expect_checked(input_identifier)
    input_element = find_input_element(input_identifier)
    raise "checkable element #{input_identifier} not found" unless input_element

    case input_element['type']
    when 'checkbox'
      input_element.value.to_i.should == 1
    when 'radio'
      input_element['checked'].should be_present
    else
      raise "element #{input_identifier} was expected to be radio or checkbox, but was a #{input_element['type']}"
    end
  end

  def expect_gold_coin_header(expected_coin_count)
    expect_content (expected_coin_count == 1 ? "1 gold coin" : "#{expected_coin_count} gold coins")
  end

  def expect_link(text, url)
    page.find(:xpath, "//a[@href='#{url}']", :text => text).should be_present
  end

  def act_via_play_box(text)
    fill_in 'command_central', :with => text
    click_button 'play_button'
  end

  def tile_fixture_path(filename)
    Rails.root.join('spec/support/fixtures/tiles', filename)  
  end

  def buttons_with_text(text)
    page.all(:xpath, "//input[@type='submit'][@value='#{text}']")  
  end

  def expect_button(text)
    buttons_with_text(text).should_not be_empty
  end

  def expect_no_button(text)
    buttons_with_text(text).should be_empty
  end

  def expect_none_selected(input_name)
    page.all(:css, "input[@name='#{input_name}']").any?(&:checked?).should_not be_true
  end

  def click_submit_in_form(form_selector)
    page.find(:css, "#{form_selector} input[@type='submit']").click
  end
end
