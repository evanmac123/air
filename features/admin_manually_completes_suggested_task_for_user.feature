Feature: Admin manually completes a suggested task for a user

  Scenario: Admin manually completes a suggested task for a user
    Given the following demo exists:
      | company name |
      | TaskCo       |
    And the following claimed users exist:
      | name | demo                 |
      | Joe  | company_name: TaskCo |
    And "Joe" has the password "foo"
    And the following suggested tasks exist:
      | name   | demo                 |
      | Task 1 | company_name: TaskCo |
      | Task 2 | company_name: TaskCo |
      | Task 3 | company_name: TaskCo |
      | Task 4 | company_name: TaskCo |
    And the task "Task 2" has prerequisite "Task 1"
    And the task "Task 4" has prerequisite "Task 3"
    And DJ cranks 10 times
    And I sign in via the login page with "Joe/foo"

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

    When I sign in via the login page with "Joe/foo"
    Then I should see "Task 2"
    And I should see "Task 3"
    But I should not see "Task 1"
    And I should not see "Task 4"

