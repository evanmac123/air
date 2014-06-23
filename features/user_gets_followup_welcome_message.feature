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
    And time moves ahead 30
    And DJ cranks 20 times
    Then "phil@example.com" should receive an email with "Play. Or die. Your choice." in the email body

  Scenario: User claims account but not enough time has passed
    When "+16175551212" sends SMS "vladig" to "+14158675309"
    And time moves ahead 29:59
    And DJ cranks 10 times
    Then "+16175551212" should not have received an SMS "Play. Or die. Your choice."
