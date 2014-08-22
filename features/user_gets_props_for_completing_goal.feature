Feature: User gets some props for finishing a goal

  Background:
    Given the following demo exists:
      | name  |
      | FooCo |
    And the following goals exist:
      | name    | achievement text    | completion sms text               | demo        |
      | winning | You won at winning! | You've won at winning everything! | name: FooCo |
    And the following rules exist:
      | reply | demo        |
      | win 1 | name: FooCo |
      | win 2 | name: FooCo |
      | win 3 | name: FooCo |
    And the rule "win 1" is associated with the goal "winning"
    And the rule "win 2" is associated with the goal "winning"
    And the rule "win 3" is associated with the goal "winning"
    And the following rule values exist:
      | value | rule         |
      | win 1 | reply: win 1 |
      | win 2 | reply: win 2 |
      | win 3 | reply: win 3 |
    And the following claimed users exist:
      | name | email            | phone number | demo        |
      | Bob  | bob@example.com  | +14155551212 | name: FooCo |
    And "Bob" has password "foobar"
    When "+14155551212" sends SMS "win 1"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should not have received SMS "You've won at winning everything!"

    When "+14155551212" sends SMS "win 2"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should not have received SMS "You've won at winning everything!"

    When "+14155551212" sends SMS "win 2"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should not have received SMS "You've won at winning everything!"

  Scenario: User gets an SMS for finishing a goal via SMS
    Given a clear email queue
    When "+14155551212" sends SMS "win 3"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should have received SMS "You've won at winning everything!"
    But "bob@example.com" should receive no email

  Scenario: User gets credit for finish goal just once
    When "+14155551212" sends SMS "win 3"
    When "+14155551212" sends SMS "win 1"
    And "+14155551212" sends SMS "win 2"
    And "+14155551212" sends SMS "win 3"
    And DJ cranks 15 times after a little while
    Then "+14155551212" should have received SMS "You've won at winning everything!" just once
