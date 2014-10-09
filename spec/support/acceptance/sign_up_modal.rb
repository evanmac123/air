module SignUpModalHelpers
  NEW_CREATOR_NAME = "Johnny Cochran"
  NEW_CREATOR_EMAIL = "mustacquit@cochranlaw.com"
  NEW_CREATOR_PASSWORD = "ojtotallydidit"
  NEW_BOARD_NAME = "Law Offices Of J. Cochran"

  def register_if_guest
    if show_register_form? # method must be implemented in test file
      page.should have_selector('#sign_up_modal', visible: true)
      fill_in_valid_form_entries
      submit_create_form
      @user = User.order("created_at DESC").first
      @user.name.should == NEW_CREATOR_NAME
      expect_pings  ['Boards - New', {}, @user], 
                    ["Creator - New", {}, @user]
    end
  end

  def fill_in_valid_form_entries
    within(create_account_form_selector) do 
      fill_in 'user[name]', with: NEW_CREATOR_NAME
      fill_in 'user[email]', with: NEW_CREATOR_EMAIL
      fill_in 'user[password]', with: NEW_CREATOR_PASSWORD
      fill_in 'board[name]', with: NEW_BOARD_NAME
    end
  end

  def submit_create_form
    element_selector = page.evaluate_script("window.pathForActionAfterRegistration")
    begin 
      click_button "Create Free Account"
    #
    # => This part for explore tile preview page.
    #
    # actionElement[0].click(); - this code should make last 
    # action that guest user had made before registration.
    # this doesn't work in tests but works in code.
    # so i have to do this action in tests manually
    rescue Capybara::Poltergeist::JavascriptError
      page.find(element_selector).click
    end
  end

  def create_account_form_selector
    "form#create_account_form"
  end
end