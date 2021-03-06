module GuestUserConversionHelpers
  def fill_in_conversion_name(name)
    within(conversion_form_selector) do
      page.find("[name='user[name]']").set(name)
    end
  end

  def fill_in_conversion_email(email)
    within(conversion_form_selector) do
      page.find("[name='user[email]']").set(email)
    end
  end

  def fill_in_conversion_password(password)
    within(conversion_form_selector) do
      page.find("[name='user[password]']").set(password)
    end
  end

  def fill_in_location_autocomplete(string)
    within(conversion_form_selector) do
      page.find("#location_name").set(string)
      # Small hack to wake up the autocomplete code
      page.execute_script("$('#location_name').focus().keydown().keyup()")
    end
  end

  def submit_conversion_form
    page.find(conversion_form_selector, visible: true)

    within(conversion_form_selector) do
      click_button 'Create account'
    end
  end

  def expect_conversion_form_header
    expect(page).to have_content("Create an account to interact with this tile and many others.")
  end
end
