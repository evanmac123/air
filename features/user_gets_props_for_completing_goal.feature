Feature: User gets some props for finishing a goal

  Background:
    Given the following demo exists:
      | company name |
      | FooCo        |
    And the following goals exist:
      | name    | achievement text    | completion sms text               | demo                |
      | winning | You won at winning! | You've won at winning everything! | company_name: FooCo |
    And the following rules exist:
      | reply | demo                |
      | win 1 | company_name: FooCo |
      | win 2 | company_name: FooCo |
      | win 3 | company_name: FooCo |
    And the rule "win 1" is associated with the goal "winning"
    And the rule "win 2" is associated with the goal "winning"
    And the rule "win 3" is associated with the goal "winning"
    And the following rule values exist:
      | value | rule         |
      | win 1 | reply: win 1 |
      | win 2 | reply: win 2 |
      | win 3 | reply: win 3 |
    And the following user exists:
      | name | phone number | demo                |
      | Bob  | +14155551212 | company_name: FooCo |
    And "Bob" has password "foobar"

#   Scenario: User gets an achievement for finishing a goal
    # When I sign in via the login page with "Bob/foobar"
    # And I go to the activity page
    # Then I should not see "You won at winning!"

    # When "+14155551212" sends SMS "win 1"
    # And I go to the activity page
    # Then I should not see "You won at winning!"

    # When "+14155551212" sends SMS "win 2"
    # And I go to the activity page
    # Then I should not see "You won at winning!"

    # When "+14155551212" sends SMS "win 2"
    # And I go to the activity page
    # Then I should not see "You won at winning!"

    # When "+14155551212" sends SMS "win 3"
    # And I go to the activity page
    # Then I should see "You won at winning!"

    # When "+14155551212" sends SMS "win 1"
    # And "+14155551212" sends SMS "win 2"
    # And "+14155551212" sends SMS "win 3"
    # And I go to the activity page
    # Then I should see "You won at winning!" just once

  Scenario: User gets a message for finishing a goal
    When "+14155551212" sends SMS "win 1"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should not have received SMS "You've won at winning everything!"

    When "+14155551212" sends SMS "win 2"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should not have received SMS "You've won at winning everything!"

    When "+14155551212" sends SMS "win 2"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should not have received SMS "You've won at winning everything!"

    When "+14155551212" sends SMS "win 3"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should have received SMS "You've won at winning everything!"

    When "+14155551212" sends SMS "win 1"
    And "+14155551212" sends SMS "win 2"
    And "+14155551212" sends SMS "win 3"
    And DJ cranks 10 times after a little while
    Then "+14155551212" should have received SMS "You've won at winning everything!" just once
