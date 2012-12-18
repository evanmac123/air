Feature: User gets timed bonus

  Background:
    Given the following demo exists:
      | name  |
      | FooCo |
    And the following claimed users exist:
      | name | email            | phone number | demo        |
      | Phil | phil@example.com | +14155551212 | name: FooCo |
      | Vlad | vlad@example.com | +16175551212 | name: FooCo |
    And the following rules exist:
      | reply       | points | demo        |
      | did a thing | 5      | name: FooCo |
    And the following rule values exist:
      | value     | rule               |
      | did thing | reply: did a thing |
    And the following timed bonus exists:
      | expires_at                | fulfilled | points | user       | demo        |
      | 2011-05-01 00:00:00 -0000 | false     | 15     | name: Phil | name: FooCo |
    And time is frozen at "2011-04-30 23:59:59 -0000"
    And "Phil" has the password "foobar"

  Scenario: User gets bonus message via SMS for acting in the proper time
    When "+14155551212" sends SMS "did thing"
    And "+16175551212" sends SMS "did thing"
    Given a clear email queue
    And DJ cranks 10 times after a little while
    Then "+14155551212" should have received an SMS including "did a thing"
    And "+14155551212" should have received an SMS including "You acted before the time limit expired! +15 points."
    But "+16175551212" should not have received an SMS including "You acted before the time limit expired"

  Scenario: User gets bonus message via email for acting in the proper time
    When "phil@example.com" sends email with subject "did thing" and body "did thing"
    And DJ cranks 10 times after a little while
    Then "phil@example.com" should receive an email with "did a thing" in the email body
    And "phil@example.com" should receive an email with "You acted before the time limit expired!" in the email body
    But "+14155551212" should not have received any SMSes

  Scenario: User gets bonus message in the flash for acting in the proper time
    When I sign in via the login page with "Phil/foobar"
    And I enter the act code "did thing"
    Then I should see "You acted before the time limit expired!"
    Given a clear email queue
    And DJ cranks 10 times after a little while
    Then "+14155551212" should not have received any SMSes
    And "phil@example.com" should receive no email

  Scenario: User doesn't get bonus if it's expired
    Given time is frozen at "2011-05-01 00:00:00 -0000"
    When "+14155551212" sends SMS "did thing"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should have received an SMS including "did a thing"
    But "+14155551212" should not have received an SMS including "You acted before the time limit expired!"

  Scenario: User gets bonus just once
    When "+14155551212" sends SMS "did thing"
    And "+14155551212" sends SMS "did thing"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should have received an SMS including "did a thing"
    And "+14155551212" should have received SMS "You acted before the time limit expired! +15 points." just once

  Scenario: User can get multiple bonuses
    Given the following timed bonus exists:
      | expires_at                | fulfilled | points | user       | demo        |
      | 2011-05-01 00:00:00 -0000 | false     | 30     | name: Phil | name: FooCo |
    When "+14155551212" sends SMS "did thing"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should have received an SMS including "did a thing"
    And "+14155551212" should have received SMS "You acted before the time limit expired! +15 points." just once
    And "+14155551212" should have received SMS "You acted before the time limit expired! +30 points." just once

  Scenario: Bonus can have custom text
    Given the following timed bonus exists:
      | expires_at                | fulfilled | points | sms text                                      | user       | demo        |
      | 2011-05-01 00:00:00 -0000 | false     | 50     | You got the lead out and got %{points} points | name: Phil | name: FooCo |    
    When "+14155551212" sends SMS "did thing"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should have received an SMS including "did a thing"
    And "+14155551212" should have received SMS "You acted before the time limit expired! +15 points." just once
    And "+14155551212" should have received SMS "You got the lead out and got 50 points" just once

