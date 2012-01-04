Feature: Admin bulk loads users

  Background:
    Given the following demo exists:
      | company_name |
      | NobodysBusiness |
    And the following user exists:
      | name | is site admin |
      | Phil | true          |
    And the following suggested_task exists:
      | name  | demo                          |
      | survey | company_name: NobodysBusiness |
    And "Phil" has the password "foo"
    And I sign in via the login page with "Phil/foo"
    And I go to the edit admin suggested task page for company "NobodysBusiness" and task "survey"

  Scenario: Admin assigns bonus points to a Suggested Task
    Then I should see "Bonus Points"
