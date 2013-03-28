module SteakHelperMethods
  def should_be_signed_out
    # Copied this directly from the Cucumber steak of the same name. Don't
    # quite understand the signifigance.
    visit '/'
    expect_marketing_page_blurb
  end

  def should_be_signed_in
    visit '/'
    expect_content "Sign Out"
  end

  def sign_out_via_link
    visit '/'
    click_link 'Sign Out'
  end
end
