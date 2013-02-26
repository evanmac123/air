module SteakHelperMethods

  # Capy2 needs links (and everything else) to be unambiguous. Most failures were fixed with specific selectors,
  # which is the philosophy most new tests should also incorporate. But for those cases where it really doesn't
  # matter, this effectively reverts back to the Capy1.x way of clicking links.
  def click_first_link(locator)
    first(:link, locator).click
  end

  # Capy2 doesn't like the fact that the visible "No Thanks" to the Quick Tour is duplicated from a non-visible template
  def dismiss_tutorial
    find('div#tutorial_introduction a#no_thanks_tutorial').click
  end

  # Need these guys to get rid of overlays for the talking-chicken tutorial and inviting people
  # to join the game. If don't get rid of them => can't click on any links because they are "covered".
  def bypass_modal_overlays(user)
    User.any_instance.stubs(:create_tutorial_if_none_yet) # Uses 'fancybox' css selectors
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
    click_button "Let's play!"
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

  def an_admin
    FactoryGirl.create :user, :is_site_admin => true  
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
    page_text.should include(expected_content)
  end

  def expect_content_case_insensitive(expected_content)
    page_text.downcase.should include(expected_content.downcase)
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

  def expect_ticket_header(expected_ticket_count)
    expect_content_case_insensitive "#{expected_ticket_count} Tickets"
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

  def current_slideshow_tile
    sleep 0.5  # Seems to help...
    # Use the z-index to determine which tile is visible
    current_tile = all('#slideshow .tile_holder').sort_by { |img| img[:style].slice(/(z-index: )(\d)/, 2) }.last
    current_tile[:id]  # 'current_tile' is a Capybara::Node::Element => return its 'id' attribute
  end

  # First is Capybara capability. Second is auxiliary gem; info can be found at:
  # https://github.com/mattheworiordan/capybara-screenshot
  def show_me_the_page
    save_and_open_page
    screenshot_and_open_image
  end
end
