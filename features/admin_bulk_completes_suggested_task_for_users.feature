Feature: Admin bulk-completes suggested task for users

  Scenario: Admin bulk-completes suggested task for users
    Given the following demo exists:
      | company name |
      | TaskCo       |
    And the following users exist:
      | name | email                | demo                  |
      | Joe    | joe@example.com    | company_name: TaskCo  |
      | Bob    | bob@example.com    | company_name: TaskCo  |
      | Fred   | fred@example.com   | company_name: TaskCo  |
      | John   | john@example.com   | company_name: TaskCo  |
      | Paul   | paul@example.com   | company_name: OtherCo |
      | George | george@example.com | company_name: TaskCo  |
    And "Joe" has password "foo"
    And "Bob" has password "foo"
    And "Fred" has password "foo"
    And the following suggested tasks exist:
      | name   | demo                 |
      | Task 1 | company_name: TaskCo |
      | Task 2 | company_name: TaskCo |
      | Task 3 | company_name: TaskCo |
      | Task 4 | company_name: TaskCo |
    And the task "Task 2" has prerequisite "Task 1"
    And the task "Task 4" has prerequisite "Task 3"
    And DJ cranks 15 times
    And "John" has completed suggested task "Task 1"
    And "George" has not had task "Task 1" suggested

    When I sign in via the login page with "Joe/foo"
    Then I should see "Task 1"
    And I should see "Task 3"
    But I should not see "Task 2"
    And I should not see "Task 4"

    When I sign in via the login page with "Bob/foo"
    Then I should see "Task 1"
    And I should see "Task 3"
    But I should not see "Task 2"
    And I should not see "Task 4"

    When I sign in via the login page with "Fred/foo"
    Then I should see "Task 1"
    And I should see "Task 3"
    But I should not see "Task 2"
    And I should not see "Task 4"

    When I sign in via the login page as an admin
    And I go to the edit admin suggested task page for company "TaskCo" and task "Task 1"
    And I fill in "Manually complete for multiple users" with the following:
    """
    joe@example.com
    bob@example.com
    malo@badexample.com
    john@example.com
    paul@example.com
    george@example.com
    """
    And I press "Manually complete"
    Then I should be on the edit admin suggested task page for company "TaskCo" and task "Task 1"
    And I should see "Bulk updates scheduled. It may take a few minutes for all updates to complete. Report will go to admins@hengage.com."
    
    Given DJ cranks 10 times

    When I sign in via the login page with "Joe/foo"
    Then I should see "Task 2"
    And I should see "Task 3"
    But I should not see "Task 1"
    And I should not see "Task 4"

    When I sign in via the login page with "Bob/foo"
    Then I should see "Task 2"
    And I should see "Task 3"
    But I should not see "Task 1"
    And I should not see "Task 4"

    When I sign in via the login page with "Fred/foo"
    Then I should see "Task 1"
    And I should see "Task 3"
    But I should not see "Task 2"
    And I should not see "Task 4"

    Then "admins@hengage.com" should receive an email
    When "admins@hengage.com" opens the email
    Then I should see the following in the email body:
    """
    Completed 2:
        joe@example.com
        bob@example.com
    """ 
    And I should see the following in the email body:
    """
    Email not in records 1:
        malo@badexample.com
    """ 
    And I should see the following in the email body:
    """
    Already completed 1:
        john@example.com
    """
    And I should see the following in the email body:
    """
    In different game 1:
        paul@example.com
    """
    And I should see the following in the email body:
    """
    Not assigned to task 1:
        george@example.com
    """
    And I should see "Not completed 4" in the email body

