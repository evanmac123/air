Feature: User gets timed bonus

  Background:
    Given the following demo exists:
      | company name |
      | FooCo        |
    And the following claimed users exist:
      | name | phone number | demo                |
      | Phil | +14155551212 | company_name: FooCo |
      | Vlad | +16175551212 | company_name: FooCo |
    And "Phil" has password "foo"
    And the following rules exist:
      | reply       | points | demo                |
      | did a thing | 5      | company_name: FooCo |
    And the following rule values exist:
      | value     | rule               |
      | did thing | reply: did a thing |
    And the following timed bonus exists:
      | expires_at                | fulfilled | points | user       | demo                |
      | 2011-05-01 00:00:00 -0000 | false     | 15     | name: Phil | company_name: FooCo |
    And time is frozen at "2011-04-30 23:59:59 -0000"

  Scenario: User gets bonus for acting in the proper time
    When "+14155551212" sends SMS "did thing"
    And "+16175551212" sends SMS "did thing"
    And DJ cranks 10 times after a little while
    And I dump all sent texts
    Then "+14155551212" should have received an SMS including "did a thing"
    And "+14155551212" should have received an SMS including "You acted before the time limit expired! +15 points."
    But "+16175551212" should not have received an SMS including "You acted before the time limit expired"

    When I sign in via the login page as "Phil/foo"
    And I go to the acts page
    Then I should see "20points"

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
      | expires_at                | fulfilled | points | user       | demo                |
      | 2011-05-01 00:00:00 -0000 | false     | 30     | name: Phil | company_name: FooCo |
    When "+14155551212" sends SMS "did thing"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should have received an SMS including "did a thing"
    And "+14155551212" should have received SMS "You acted before the time limit expired! +15 points." just once
    And "+14155551212" should have received SMS "You acted before the time limit expired! +30 points." just once

  Scenario: Bonus can have custom text
    Given the following timed bonus exists:
      | expires_at                | fulfilled | points | sms text                                      | user       | demo                |
      | 2011-05-01 00:00:00 -0000 | false     | 50     | You got the lead out and got %{points} points | name: Phil | company_name: FooCo |    
    When "+14155551212" sends SMS "did thing"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should have received an SMS including "did a thing"
    And "+14155551212" should have received SMS "You acted before the time limit expired! +15 points." just once
    And "+14155551212" should have received SMS "You got the lead out and got 50 points" just once

