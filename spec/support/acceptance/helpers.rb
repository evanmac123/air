module SteakHelperMethods

  # Capy2 needs links (and everything else) to be unambiguous. Most failures were fixed with specific selectors,
  # which is the philosophy most new tests should also incorporate. But for those cases where it really doesn't
  # matter, this effectively reverts back to the Capy1.x way of clicking links.
  def click_first_link(locator)
    first(:link, locator).click
  end

  def close_tutorial_lightbox
    find('#get_started_lightbox #close_get_started_lightbox').click
  end

  # Need these guys to get rid of overlays for the talking-chicken tutorial and inviting people
  # to join the game. If don't get rid of them => can't click on any links because they are "covered".
  def bypass_modal_overlays(user)
    user.update_attribute :session_count, 10              # Uses 'facebox'  css selectors
  end

  def fill_in_signin_fields(user, password)
    visit signin_page
    fill_in "session[email]", :with => user.email
    fill_in "session[password]", :with => password
  end

  def signin_as(user, password)
    #Note: In controller specs you can just use Clearance's sign_in_as(user) method instead
    # Or even try Clearance's sign_in() -- it creates a user for you
    fill_in_signin_fields(user, password)
    click_button "Log In"
  end

  def signin_as_admin
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

  # These methods are convenient for calling with the Clearance backdoor,
  # e.g.:
  #
  # visit foo_path(as: an_admin)
  # visit foo_path(as: a_client_admin)
  # visit foo_path(as: a_regular_user)
  #
  # reads much better than the alternative using just FactoryGirl

  def an_admin
    FactoryGirl.create :user, is_site_admin: true  
  end

  def a_client_admin(demo = nil)
    if demo
      FactoryGirl.create :user, is_client_admin: true, demo: demo
    else
      FactoryGirl.create :user, is_client_admin: true
    end
  end

  def a_regular_user
    FactoryGirl.create :user
  end

  def a_guest_user
    FactoryGirl.create :guest_user
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

  def expect_avatar_in_masthead(expected_filename)
    avatar = page.find(:css, 'img.avatar48')
    avatar_url = avatar['src'].gsub(/\?.*$/, '') # Chop off query params
    avatar_url.should =~ /#{expected_filename}$/
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
    page.should have_content(expected_content)
  end

  def expect_content_case_insensitive(expected_content)
    page_text.downcase.should include(expected_content.downcase)
  end

  def expect_no_content(unexpected_content)
    page.should have_no_content(unexpected_content)
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

  def expect_ticket_header(expected_ticket_count)
    expect_content_case_insensitive "tickets #{expected_ticket_count}"
  end

  def expect_raffle_entries count
    page.find("#raffle_entries").text.should == count.to_s
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

  # My first custom matcher! Yippee!!
  RSpec::Matchers.define :be_tile do |tile|
    match do |current_tile|
      current_tile.should == tile.id.to_s
    end

    failure_message_for_should do |current_tile|
      "expected current tile to have an id of #{current_tile}, but got #{tile.id} instead "
    end

    failure_message_for_should_not do |current_tile|
      "expected current tile *not* to have an id of #{current_tile}, but that is what we got"
    end
  end

  def click_carousel_tile(tile)
    find("a[href='#{tile_path(tile)}']").click
  end

  def show_previous_tile
    page.find("#prev").click
  end

  def show_next_tile
    page.find("#next").click
  end

  # First is Capybara capability. Second is auxiliary gem; info can be found at:
  # https://github.com/mattheworiordan/capybara-screenshot
  def show_me_the_page
    save_and_open_page
    screenshot_and_open_image
  end

  def expect_marketing_page_blurb
    expect_content "Engage employees like their favorite apps"
  end

  def expect_disabled(element)
    element["disabled"].should_not be_nil
  end

  def expect_not_disabled(element)
    element["disabled"].should be_nil
  end

  def wait_until(timeout = Capybara.default_wait_time)
    Capybara.send(:timeout, timeout, page.driver) { yield }
  end

  def click_play_button
    page.find('#play_button').click
  end

  def expect_game_referrer_id(expected_id)
    expected_id.to_s.should == page.find('#user_game_referrer_id').value
  end

  def open_admin_nav
    page.find("#admin_toggle").click()
  end

  def spoof_client_device(device_type)
    user_agent = case device_type.to_s
                   when 'desktop'
                     # pretend to be chrome on a Linux box
                     "Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.48 Safari/537.36"
                   when 'tablet'
                     # pretend to be an ipad
                     "Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B334b Safari/531.21.10"
                   when 'mobile'
                     # pretend to be an iphone
                     "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5"
                   else
                     raise "Don't recognize spoof device type #{device_type}"
                   end

    if page.driver.respond_to?(:headers=)
      # This is the Poltergeist way to do things
      page.driver.headers = {'User-Agent' => user_agent}
    else
      raise "You must use Poltergeist as the driver if you want to use #spoof_client_device"
    end
  end

  def site_tutorial_lightbox_selector
    "#get_started_lightbox"
  end

  def site_tutorial_content
    "Airbo is an interactive communication tool. Get started by clicking on a tile. Interact and answer questions to earn points."
  end

  def expect_no_site_tutorial_lightbox
    page.all(site_tutorial_lightbox_selector).should be_empty
  end
  
  def close_conversion_form
    evaluate_script("$('#guest_conversion_form_wrapper').trigger('close')")
    page.find('#guest_conversion_form_wrapper', visible: false)
  end

  def conversion_form_selector
    "form[action='#{guest_user_conversions_path}']"
  end

  def wait_for_conversion_form
    page.should have_selector(conversion_form_selector, visible: true)
  end

  def expect_conversion_form
    Capybara.default_wait_time = 30
    wait_for_conversion_form

    within(conversion_form_selector) do
      page.find("input[type=text][name='user[name]']").should be_present
      page.find("input[type=text][name='user[email]']").should be_present
      page.find("input[type=password][name='user[password]']").should be_present
    end
  end

  def expect_counter_text(counter, max_characters)
    counter.text.should == counter_text(max_characters)
  end

  def expect_character_counter_for(selector, max_characters)
    counter = page.find(counter_selector(selector))
    expect_counter_text(counter, max_characters)
  end

  def counter_text(max_characters)
    "#{max_characters} CHARACTERS LEFT"  
  end

  def expect_character_counter_for_each(selector, max_characters)
    page.all(counter_selector(selector)) do |counter|
      expect_counter_text(counter, max_characters)
    end
  end

  def counter_selector(associated_selector)
    "#{associated_selector} + .character-counter"  
  end

  def expect_ping event, properties, user = nil
    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear
    #p FakeMixpanelTracker.tracked_events
    properties.merge!(user.data_for_mixpanel) if user
    FakeMixpanelTracker.should have_event_matching(event, properties)
  end

  def welcome_message
    "Airbo is an interactive communication tool. Get started by clicking on a tile. Interact and answer questions to earn points."
  end
end
