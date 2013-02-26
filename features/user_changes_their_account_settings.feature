Feature: User can edit their account settings

  Background:
    Given the following demo exists:
      | name         |
      | Big Machines |
    Given the following user with phone exist:
      | name  | phone number | email             | demo              |
      | Phil  | +14155551212 | phil@example.com  | name: BigMachines |
      | Alice | +18085551212 | alice@example.com | name: BigMachines |
    And "Phil" has the password "foobar"
    And I sign in via the login page with "Phil/foobar"
    And I go to the settings page for "Phil"

  Scenario: User changes SMS slug
    When I fill in "Change your username." with "awesomed00d"
    And I press the button to save the user's settings
    And "+14155551212" sends SMS "myid"
    Then "+14155551212" should have received an SMS "Your username is awesomed00d."

  Scenario: User chooses an SMS slug that's already taken
    Given the following user exists:
      | name | phone number | 
      | Vlad | +14156171212 | 
    And "Vlad" has the SMS slug "awesomed00d"
    When I fill in "Change your username." with "awesomed00d"
    And I press the button to save the user's settings
    And "+14155551212" sends SMS "myid"
    Then I should see "Sorry, that username is already taken."
    And "+14155551212" should not have received an SMS including "awesomed00d"

  Scenario: User enters their demographic information
    When I fill in all of my demographic information
    And I press the button to save the user's settings

    Then I should be on the settings page
    And I should see "OK, your settings were updated."
    And "Male" should be chosen
  
  Scenario: User sees their mobile number on their settings
    When I go to the settings page
    Then "Mobile number" should have value "(415) 555-1212"

  Scenario: User can change their own mobile number
    When I go to the settings page
    And I fill in "Mobile number" with "(415) 261-3077"
    And I press the button to save notification settings
    Then I should be on the settings page
    Then I should see "We have sent a verification"
    And "Mobile number" should have value "(415) 555-1212"
    And I should see "To verify the number (415) 261-3077, please enter the validation code we sent to that number:"
    When DJ works off
    And "Phil" should receive an SMS containing their new phone validation code
    When "Phil" fills in the new phone validation field with their validation code
    And I press the button to verify the new phone number
    Then I should see "You have updated your phone number"
    And "Mobile number" should have value "(415) 261-3077"

  Scenario: User tries to change their mobile number to a bad (non-ten-digit) number
    When I go to the settings page
    And I fill in "Mobile number" with "(415) 261-307"
    And I press the button to save notification settings
    Then I should be on the settings page
    And I should not see "We have sent a verification"
    But I should see "Please fill in all ten digits of your mobile number, including the area code"
    And "Mobile number" should have value "(415) 555-1212"

    When I fill in "Mobile number" with "(415) 261-30777"
    And I press the button to save notification settings
    Then I should be on the settings page
    And I should not see "We have sent a verification"
    But I should see "Please fill in all ten digits of your mobile number, including the area code"
    And "Mobile number" should have value "(415) 555-1212"

    When I fill in "Mobile number" with "1-415-261-3077"
    And I press the button to save notification settings
    Then I should be on the settings page
    And I should see "We have sent a verification"
    When DJ works off
    Then "Phil" should receive an SMS containing their new phone validation code

  Scenario: User can cancel new phone number by re-entering their current one
    When I go to the settings page
    And I fill in "Mobile number" with "(415) 261-3077"
    And I press the button to save notification settings
    Then I should see "To verify the number (415) 261-3077, please enter the validation code we sent to that number:"
    When I fill in "Mobile number" with "(415) 555-1212"
    And I press the button to save notification settings
    And I press the button to save notification settings
    Then I should not see "please enter the validation code"

  Scenario: User changes mobile number in a game with custom phone number and gets message from that phone number
    Given the following demo exists:
      | name     | phone number |
      | CustomCo | +14048765309 |
    And the following user exists:
      | name      | phone number | demo           |
      | Joe Smith | +14105551212 | name: CustomCo |
    And "Joe Smith" has the password "foobar"
    When I sign in via the login page with "Joe Smith/foobar"
    And I go to the settings page
    And I clear all sent texts
    And I fill in "Mobile number" with "(515) 261-3077"
    And I press the button to save notification settings
    And DJ works off
    Then I should be on the settings page
    Then I should see "We have sent a verification"
    And "+15152613077" should not have received an SMS from the default phone number
    But "+15152613077" should have received an SMS from "+14048765309"
    
  Scenario: User gets error messages when inputs wrong validation code to change mobile number
    When I go to the settings page
    And I fill in "Mobile number" with "(415) 261-3077"
    And I press the button to save notification settings
    Then I should be on the settings page
    Then I should see "We have sent a verification"
    And "Mobile number" should have value "(415) 555-1212"
    When DJ works off
    Then "Phil" should receive an SMS containing their new phone validation code
    When "Phil" fills in the new phone validation field with the wrong validation code
    And I press the button to verify the new phone number
    Then I should see "Sorry, the code you entered was invalid. Please try typing it again."
    And I should see "To verify the number (415) 261-3077, please enter the validation code we sent to that number:"

  Scenario: User can enter a blank mobile number
    When I go to the settings page
    And I fill in "Mobile number" with ""
    And I press the button to save notification settings
    Then I should not see "Phone number can't be blank"
    And I should not see "() -"
    But I should see "OK, you won't get any more text messages from us."
    And the mobile number field should be blank
    And I should not see the new phone validation field

  Scenario: User tries to change their mobile number to a taken number
    When I go to the settings page
    And I fill in "Mobile number" with "808-555-1212"
    And I press the button to save notification settings
    Then I should be on the settings page
    And I should see "Sorry, but that phone number has already been taken. Need help? Contact support@hengage.com"
    And there should be a mail link to support in the flash
    And "Mobile number" should have value "(415) 555-1212"

  Scenario: Nothing much happens if phone number is left unchanged
    When I go to the settings page
    And I fill in "Mobile number" with "4155551212"
    And I press the button to save notification settings
    Then I should be on the settings page
    And "Mobile number" should have value "(415) 555-1212"
    And I should not see the new phone validation field
