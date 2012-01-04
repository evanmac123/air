Feature: Admin bulk loads users

  Background:
    Given the following demo exists:
      | company name |
      | NobodysBusiness |
    And the following user exists:
      | name | is site admin |
      | Phil | true          |
    And the following suggested task exists:
      | name            | demo                          | bonus points |
      | ride a tricycle | company name: NobodysBusiness | 11           |


    And "Phil" has the password "foo"
    And I sign in via the login page with "Phil/foo"


  Scenario: Admin assigns bonus points to a Suggested Task
    When I go to the edit admin suggested task page for company "NobodysBusiness" and task "ride a tricycle"
    Then I should see "Bonus points"
    And I should see "11"
    When I enter "15" into the bonus points field
    And I click "Update Suggested Task"
    Then I should see "15"
    When I go to the homepage
    Then I dump the page
    Then I should see "0points"
