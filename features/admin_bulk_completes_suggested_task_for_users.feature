Feature: Admin bulk-completes suggested task for users

  @javascript
  Scenario: Admin bulk-completes suggested task for users
    Given the following demo exists:
      | company name |
      | TaskCo       |
    And the following claimed users exist:
      | name   | phone number | email              | demo                  |
      | Joe    | +14155551212 | joe@example.com    | company_name: TaskCo  |
      | Bob    | +16175551212 | bob@example.com    | company_name: TaskCo  |
      | Fred   | +19085551212 | fred@example.com   | company_name: TaskCo  |
      | John   | +12135551212 | john@example.com   | company_name: TaskCo  |
      | Paul   | +13125551212 | paul@example.com   | company_name: OtherCo |
      | George | +18085551212 | george@example.com | company_name: TaskCo  |
    And "Joe" has password "foobar"
    And "Bob" has password "foobar"
    And "Fred" has password "foobar"
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
    And DJ cranks 5 times after a little while
    And I clear all sent texts

    When I sign in via the login page with "Joe/foobar"
    Then I should see "Task 1"
    And I should see "Task 3"
    But I should not see "Task 2"
    And I should not see "Task 4"

    When I sign in via the login page with "Bob/foobar"
    Then I should see "Task 1"
    And I should see "Task 3"
    But I should not see "Task 2"
    And I should not see "Task 4"

    When I sign in via the login page with "Fred/foobar"
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

    When I sign in via the login page with "Joe/foobar"
    Then I should see "Task 2"
    And I should see "Task 3"
    But I should not see "Task 1"
    And I should not see "Task 4"

    When I sign in via the login page with "Bob/foobar"
    Then I should see "Task 2"
    And I should see "Task 3"
    But I should not see "Task 1"
    And I should not see "Task 4"

    When I sign in via the login page with "Fred/foobar"
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

    When DJ cranks 10 times after a little while
    Then "+14155551212" should have received an SMS "Congratulations! You've completed a daily dose."
    And "+14155551212" should have received an SMS "Congratulations! You've completed a daily dose."
    But "+19085551212" should not have received any SMSes
    And "+18085551212" should not have received any SMSes
    And "+12135551212" should not have received any SMSes
    And "+13125551212" should not have received any SMSes
    But "+19085551212" should not have received any SMSes

