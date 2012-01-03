Feature: User can Change their mobile number

  Background:
    Given the following users exists:
      | name | phone_number |
      | Bob  | +14155551212 |
      | Fred | +16178675309 |
    And "Bob" has the password "bobby"
    And "Bob" has the unique ID "bobbarino"
    And I sign in via the login page as "Bob/bobby"

  Scenario: User sees their mobile number on their profile
    When I go to the profile page for "Bob"
    Then I should see "(415) 555-1212"

  Scenario: User doesn't see anyone else's mobile number
    When I go to the profile page for "Fred"
    Then I should not see "(617) 867-5309"
    And I should not see "Enter your new mobile number"

  Scenario: User can change their own mobile number
    When I go to the profile page for "Bob"
    And I fill in "Enter your new mobile number" with "(900) 939-4956"
    And I press the button to submit the mobile number
    Then I should be on the profile page for "Bob"
    Then I should see "We have sent a verification"
    And I should see "(900) 939-4956"
    When DJ cranks 5 times
    And "Bob" should receive an SMS containing their new phone validation code
    When "Bob" fills in the new phone validation field with their validation code
    And I press the button to verify the new phone number
    Then I should see "You have updated your phone number"

  Scenario: User gets error messages when inputs wrong validation code to change mobile number
    When I go to the profile page for "Bob"
    And I fill in "Enter your new mobile number" with "(900) 939-4956"
    And I press the button to submit the mobile number
    Then I should be on the profile page for "Bob"
    Then I should see "We have sent a verification"
    And I should see "(900) 939-4956"
    When DJ cranks 5 times
    And "Bob" should receive an SMS containing their new phone validation code
    When "Bob" fills in the new phone validation field with the wrong validation code
    And I press the button to verify the new phone number
    Then I should see "the code you entered was invalid"

  Scenario: User can enter a blank mobile number
    When I go to the profile page for "Bob"
    And I fill in "Enter your new mobile number" with ""
    And I press the button to submit the mobile number
    Then I should not see "Phone number can't be blank"
    And I should not see "() -"
    But I should see "OK, you won't get any more text messages from us until such time as you enter a mobile number again."
    And I should see "No mobile number. Please enter one if you'd like to play using text messaging."
    And the mobile number field should be blank

  Scenario: User has trouble updating their mobile number
    When I go to the profile page for "Bob"
    And I fill in "Enter your new mobile number" with "(617) 867-5309"
    And I press the button to submit the mobile number
    Then I should be on the profile page for "Bob"
    And I should see "Sorry, but that phone number has already been taken. Need help? Contact support@hengage.com"
    And I should see "(415) 555-1212"

  Scenario: User gets error when updating her phone number to what it's already set to
    When I go to the profile page for "Bob"
    And I fill in "Enter your new mobile number" with "4155551212"
    And I press the button to submit the mobile number
    Then I should be on the profile page for "Bob"
    And I should see "That already IS your phone number. No action taken."
    And I should see "(415) 555-1212"
