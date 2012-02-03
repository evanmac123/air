Feature: User can edit their account settings

  Background:
    Given the following demo exists:
      | name |
      | Big Machines |
    Given the following claimed users exist:
      | name  | phone number | email             | demo                      |
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
    And "Date of Birth" should have value "September 10, 1977"

  Scenario: User can change their location    
    Given the following locations exist:
      | name         | demo |
      | Philadelphia | name: BigMachines |
      | Baltimore    | name: BigMachines |    
    When I go to the settings page for "Phil"
    Then I should see "Location"
    When I select "Baltimore" from "Location"
    And I press the button to save the user's settings
    Then "Location" should have "Baltimore" selected
    And I should see "OK, your settings were updated."

  Scenario: User doesn't see location dropdown if demo has no locations
    Then I should not see "Location"
    And I should not see a form field called "Location"
  
  Scenario: User can choose notification by email
    When I sign in via the login page with "Phil/foobar"
    And I go to the settings page
    And I choose "Email"
    And I press the button to save notification settings
    And "+18085551212" sends SMS "follow phil"
    And DJ cranks 5 times

    Then "phil@example.com" should have received a follow notification email about "Alice"
    But "+14155551212" should not have received any SMSes

  Scenario: User who gets notification by email and is in a demo with a custom phone number sees that number
    Given the following demo exists:
      | name | phone number |
      | CustomCo     | +19005551212 |
    And the following claimed users exists:
      | name   | phone number | email              | demo                   |
      | Frank  | +18885551212 | frank@example.com  | name: CustomCo |
      | George | +18765551212 | george@example.com | name: CustomCo |
    And "Frank" has the password "quuxstein"

    When I sign in via the login page with "Frank/quuxstein"
    And I go to the settings page
    And I choose "Email"
    And I press the button to save notification settings
    And "+18765551212" sends SMS "follow frank"
    And DJ cranks 5 times

    Then "frank@example.com" should have received a follow notification email about "George" with phone number "(900) 555-1212"
    But "+18885551212" should not have received any SMSes

  Scenario: User can choose notification by SMS
    When I sign in via the login page with "Phil/foobar"
    And I go to the settings page
    And I choose "SMS/text message"
    And I press the button to save notification settings
    And "+18085551212" sends SMS "follow phil"
    And DJ cranks 5 times

    Then "+14155551212" should have received SMS "Alice has asked to be your fan. Text\nYES to accept,\nNO to ignore (in which case they won't be notified)"
    And "phil@example.com" should have no emails

  Scenario: User can choose notification by email and SMS
    When I sign in via the login page with "Phil/foobar"
    And I go to the settings page
    And I choose "Both"
    And I press the button to save notification settings
    And "+18085551212" sends SMS "follow phil"
    And DJ cranks 5 times

    Then "+14155551212" should have received SMS "Alice has asked to be your fan. Text\nYES to accept,\nNO to ignore (in which case they won't be notified)"
    And "phil@example.com" should have received a follow notification email about "Alice"

  Scenario: User can choose notification by neither email nor SMS
    When I sign in via the login page with "Phil/foobar"
    And I go to the settings page
    And I choose "No notifications"
    And I press the button to save notification settings
    And "+18085551212" sends SMS "follow phil"
    And DJ cranks 5 times

    Then "+14155551212" should not have received any SMSes
    And "phil@example.com" should have no emails

  Scenario: User sees their mobile number on their settings
    When I go to the settings page
    Then "Mobile Number" should have value "(415) 555-1212"

  Scenario: User can change their own mobile number
    When I go to the settings page
    And I fill in "Mobile Number" with "(415) 261-3077"
    And I press the button to save notification settings
    Then I should be on the settings page
    Then I should see "We have sent a verification"
    And "Mobile Number" should have value "(415) 555-1212"
    And I should see "To verify the number (415) 261-3077, please enter the validation code we sent to that number:"
    When DJ cranks 5 times
    And "Phil" should receive an SMS containing their new phone validation code
    When "Phil" fills in the new phone validation field with their validation code
    And I press the button to verify the new phone number
    Then I should see "You have updated your phone number"
    And "Mobile Number" should have value "(415) 261-3077"

  Scenario: User gets error messages when inputs wrong validation code to change mobile number
    When I go to the settings page
    And I fill in "Mobile Number" with "(415) 261-3077"
    And I press the button to save notification settings
    Then I should be on the settings page
    Then I should see "We have sent a verification"
    And "Mobile Number" should have value "(415) 555-1212"
    When DJ cranks 5 times
    Then "Phil" should receive an SMS containing their new phone validation code
    When "Phil" fills in the new phone validation field with the wrong validation code
    And I press the button to verify the new phone number
    Then I should see "Sorry, the code you entered was invalid. Please try typing it again."
    And I should see "To verify the number (415) 261-3077, please enter the validation code we sent to that number:"

  Scenario: User can enter a blank mobile number
    When I go to the settings page
    And I fill in "Mobile Number" with ""
    And I press the button to save notification settings
    Then I should not see "Phone number can't be blank"
    And I should not see "() -"
    But I should see "OK, you won't get any more text messages from us."
    And the mobile number field should be blank
    And I should not see the new phone validation field

  Scenario: User tries to change their mobile number to a taken number
    When I go to the settings page
    And I fill in "Mobile Number" with "808-555-1212"
    And I press the button to save notification settings
    Then I should be on the settings page
    And I should see "Sorry, but that phone number has already been taken. Need help? Contact support@hengage.com"
    And there should be a mail link to support in the flash
    And "Mobile Number" should have value "(415) 555-1212"

  Scenario: Nothing much happens if phone number is left unchanged
    When I go to the settings page
    And I fill in "Mobile Number" with "4155551212"
    And I press the button to save notification settings
    Then I should be on the settings page
    And "Mobile Number" should have value "(415) 555-1212"
    And I should not see the new phone validation field
