Feature: Admin manually completes a suggested task for a user

  @javascript
  Scenario: Admin manually completes a suggested task for a user
    Given the following demo exists:
      | company name |
      | TaskCo       |
    And the following claimed users exist:
      | name | phone number | demo                 |
      | Joe  | +14155551212 | company_name: TaskCo |
    And "Joe" has the password "foobar"
    And the following suggested tasks exist:
      | name   | demo                 |
      | Task 1 | company_name: TaskCo |
      | Task 2 | company_name: TaskCo |
      | Task 3 | company_name: TaskCo |
      | Task 4 | company_name: TaskCo |
    And the task "Task 2" has prerequisite "Task 1"
    And the task "Task 4" has prerequisite "Task 3"
    And DJ cranks 10 times
    And I sign in via the login page with "Joe/foobar"

    Then I should see "Task 1"
    And I should see "Task 3"
    But I should not see "Task 2"
    And I should not see "Task 4"

    When I sign in via the login page as an admin
    And I go to the admin "TaskCo" demo page
    And I follow "J"
    And I follow "Joe"
    And I press "Complete Task 1 for Joe"
    Then I should see "Task 1 manually completed for Joe"
    And I should not see an input with value "Complete Task 1 for Joe"
    And I should not see an input with value "Complete Task 4 for Joe"
    But I should see an input with value "Complete Task 2 for Joe"
    And I should see an input with value "Complete Task 3 for Joe"

    When I sign in via the login page with "Joe/foobar"
    Then I should see "Task 2"
    And I should see "Task 3"
    But I should not see "Task 1"
    And I should not see "Task 4"

    When DJ cranks 5 times after a little while
    And "+14155551212" should have received an SMS "Congratulations! You've completed a daily dose."
