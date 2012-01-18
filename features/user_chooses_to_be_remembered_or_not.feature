Feature: User can choose whether or not to be remembered
  Background:
    Given the following user exists:
      | name | email           |
      | Bob  | bob@example.com |
    And "Bob" has the password "foo"
    When I go to the login page
    And I fill in the login fields as "Bob/foo"

  Scenario: User wants to be remembered
    When I check the remember-me checkbox
    And I press "Sign in"
    Then I should be on the activity page

    When 1 month passes
    And I go to the activity page
    Then I should be on the activity page
    And I should not see the session expiration message

    When 18 months pass
    And I go to the activity page
    Then I should be on the activity page
    And I should not see the session expiration message

  Scenario: User doesn't want to be remembered
    When I press "Sign in"
    Then I should be on the activity page

    When 4 minutes pass
    And I go to the activity page
    Then I should be on the activity page
    And I should not see the session expiration message

    When 4 minutes pass
    And I go to the activity page
    Then I should be on the activity page
    And I should not see the session expiration message

    When 6 minutes pass
    And I go to the activity page
    Then I should be on the login page
    And I should see the session expiration message
