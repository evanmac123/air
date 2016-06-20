module SteakHelperMethods
  def should_be_signed_out
    # Copied this directly from the Cucumber steak of the same name. Don't
    # quite understand the signifigance.
    expect_content "Sign-in"
  end

  def should_be_signed_in
    expect_content "Sign Out"
  end

  def sign_out_via_link
    click_link 'Sign Out'
  end
end
