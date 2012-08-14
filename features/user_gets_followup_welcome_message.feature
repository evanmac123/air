Feature: User gets followup welcome message at some point after starting the game

  Background:
    Given time is frozen at "2011-05-01 12:00:00 EST"
    And the following demo exists:
      | name         | followup welcome message   | followup welcome message delay | phone number |
      | FooCorp      | Play. Or die. Your choice. | 30                             | +14158675309 |
    And the following users exist:
      | name | email            | demo          | claim code |
      | Phil | phil@example.com | name: FooCorp |            |
      | Vlad | vlad@example.com | name: FooCorp | vladig     |
    And "phil@example.com" has received an invitation

  Scenario: User gets followup welcome message after accepting invitation on Web
    When "phil@example.com" opens the email
    And I click the play now button in the email
    When I fill in "Enter your mobile number" with "(415) 261-3077"
    And I fill in "Choose a password" with "ohyeah"
    And I fill in "Confirm password" with "ohyeah"
    And I check "Terms and conditions"
    And I press "Join the game"
    And "Phil" fills in the new phone validation field with their validation code
    And I press "Validate phone"
    And time moves ahead 30
    And DJ cranks 20 times
    Then "+14152613077" should have received an SMS "Play. Or die. Your choice."
    And "phil@example.com" should receive an email with "Play. Or die. Your choice." in the email body

  Scenario: User gets followup welcome message after claiming account via SMS
    When "+16175551212" sends SMS "vladig" to "+14158675309"
    And time moves ahead 30
    And DJ cranks 10 times
    Then "+16175551212" should have received an SMS "Play. Or die. Your choice."

  Scenario: User with email notification method gets only welcome email message
    Given "Phil" has notification method "email"
    When "phil@example.com" opens the email
    And I click the play now button in the email
    Given a clear email queue
    When I fill in "Enter your mobile number" with "(415) 261-3077"
    And I fill in "Choose a password" with "ohyeah"
    And I fill in "Confirm password" with "ohyeah"
    And I check "Terms and conditions"
    And I press "Join the game"
    And "Phil" fills in the new phone validation field with their validation code
    And I press "Validate phone"
    And time moves ahead 30
    And DJ cranks 20 times
    Then "+14152613077" should not have received an SMS including "Play. Or die."
    And "phil@example.com" should receive an email with "Play. Or die. Your choice." in the email body

  Scenario: User with SMS notification method gets only welcome email message
    Given "Phil" has notification method "sms"
    When "phil@example.com" opens the email
    And I click the play now button in the email
    Given a clear email queue
    When I fill in "Enter your mobile number" with "(415) 261-3077"
    And I fill in "Choose a password" with "ohyeah"
    And I fill in "Confirm password" with "ohyeah"
    And I check "Terms and conditions"
    And I press "Join the game"
    And "Phil" fills in the new phone validation field with their validation code
    And I press "Validate phone"
    And time moves ahead 30
    And DJ cranks 10 times
    Then "phil@example.com" should receive no emails
    But "+14152613077" should have received an SMS "Play. Or die. Your choice."

  Scenario: User accepts invitation but not enough time has passed
    When "phil@example.com" opens the email
    And I click the play now button in the email
    When I fill in "Enter your mobile number" with "(415) 261-3077"
    And I fill in "Choose a password" with "ohyeah"
    And I fill in "Confirm password" with "ohyeah"
    And I check "Terms and conditions"
    And I press "Join the game"
    And "Phil" fills in the new phone validation field with their validation code
    And I press "Validate phone"
    And time moves ahead 29:59
    And DJ cranks 10 times
    Then "+14152613077" should not have received an SMS including "Play. Or die. Your choice."

  Scenario: User claims account but not enough time has passed
    When "+16175551212" sends SMS "vladig" to "+14158675309"
    And time moves ahead 29:59
    And DJ cranks 10 times
    Then "+16175551212" should not have received an SMS "Play. Or die. Your choice."
