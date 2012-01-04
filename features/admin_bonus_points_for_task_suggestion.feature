Feature: Admin bulk loads users

  Background:
    Given the following demo exists:
      | company name |
      | NobodysBusiness |
    And the following user exists:
      | name | is site admin |
      | Phil | true          |
    And "Phil" has the password "foo"
    And I sign in via the login page with "Phil/foo"
    And I go to the create new suggested task page for "NobodysBusiness"

  Scenario: Admin assigns bonus points to a Suggested Task
    Then I should see "Bonus Points"
