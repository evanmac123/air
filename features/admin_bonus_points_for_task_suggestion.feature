Feature: Admin sets bonus points for tasks

  Background:
    Given the following demo exists:
      | name |
      | NobodysBusiness |
    And the following claimed user exists:
      | name | phone number | is site admin | demo                          |
      | Phil | +14155551212 | true          | name: NobodysBusiness |
    And the following task exists:
      | name            | demo                          | bonus points |
      | ride a tricycle | name: NobodysBusiness | 11           |


    And "Phil" has the password "foobar"
    And I sign in via the login page with "Phil/foobar"
    And DJ cranks 5 times


  Scenario: Admin assigns bonus points to a Task
    When I go to the edit admin task page for company "NobodysBusiness" and task "ride a tricycle"
    Then I should see "Bonus points"
    And I should see an input with value "ride a tricycle"
    And I should see "11"

    When I fill in "Bonus points" with "15"
    And I press "Update Task"
    Then I should see "15"

     When I go to the homepage
    # Then I should see "0points"
     Then I should not see "15 pts"

    When I go to the edit admin demo user page for company "NobodysBusiness" and user "Phil"
    Then I should see an input with value "Phil"
    When I press "Complete ride a tricycle for Phil"
    And I click "OK"
    And I go to the homepage
    # Then I should see "15points"
    And I should see "15 pts Phil I completed a daily dose!"

    When DJ cranks 10 times after a little while
    And "+14155551212" should have received an SMS "Congratulations! You've earned 15 bonus points for completing a daily dose."
