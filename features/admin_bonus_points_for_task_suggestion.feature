Feature: Admin sets bonus points for suggested tasks

  Background:
    Given the following demo exists:
      | company name |
      | NobodysBusiness |
    And the following claimed user exists:
      | name | phone number | is site admin | demo                          |
      | Phil | +14155551212 | true          | company_name: NobodysBusiness |
    And the following suggested task exists:
      | name            | demo                          | bonus points |
      | ride a tricycle | company_name: NobodysBusiness | 11           |


    And "Phil" has the password "foo"
    And I sign in via the login page with "Phil/foo"
    And DJ cranks 5 times


  Scenario: Admin assigns bonus points to a Suggested Task
    When I go to the edit admin suggested task page for company "NobodysBusiness" and task "ride a tricycle"
    Then I should see "Bonus points"
    And I should see an input with value "ride a tricycle"
    And I should see "11"

    When I fill in "Bonus points" with "15"
    And I press "Update Suggested task"
    Then I should see "15"

    When I go to the homepage
    Then I should see "0points"
    And I should not see "15 pts"

    When I go to the edit admin demo user page for company "NobodysBusiness" and user "Phil"
    Then I should see an input with value "Phil"
    When I press "Complete ride a tricycle for Phil"
    And I click "OK"
    And I go to the homepage
    Then I should see "15points"
    And I should see "15 pts Phil I completed a daily dose!"

    When DJ cranks 5 times after a little while
    And "+14155551212" should have received an SMS "Congratulations! You've earned 15 bonus points for completing a daily dose."
