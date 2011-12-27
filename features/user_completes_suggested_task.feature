Feature: User completes suggested task

  Background:
    Given the following demo exists:
      | company name |
      | TaskCo       |
    And the following claimed user exists:
      | name | phone number | demo                 |
      | Joe  | +14152613077 | company_name: TaskCo |
    And "Joe" has the password "foo"
    And the following suggested tasks exist:
      | name        | demo                 |
      | Rule task 1 | company_name: TaskCo |
      | Rule task 2 | company_name: TaskCo |
      | Rule task 3 | company_name: TaskCo |
      | Rule task 4 | company_name: TaskCo |
      | Rule task 5 | company_name: TaskCo |
      | Rule task 6 | company_name: TaskCo |
    And the following rules exist:
      | reply | demo                 |
      | did 1 | company_name: TaskCo |
    And the following rule value exists:
      | value | is primary | rule         |
      | do 1  | true       | reply: did 1 |
    And the following rule trigger exists:
      | rule         | suggested task    |
      | reply: did 1 | name: Rule task 1 |
      | reply: did 5 | name: Rule task 5 |
    And the task "Rule task 2" has prerequisite "Rule task 1"
    And the task "Rule task 4" has prerequisite "Rule task 3"
    And the task "Rule task 6" has prerequisite "Rule task 5"
    And DJ cranks 10 times
    When I sign in via the login page with "Joe/foo"
    Then I should see "Rule task 1"
    And I should see "Rule task 3"
    And I should see "Rule task 5"
    But I should not see "Rule task 2"
    And I should not see "Rule task 4"
    And I should not see "Rule task 6"

  Scenario: User completes suggested task by acting according to rule
    When "+14152613077" sends SMS "do 1"
    Then "+14152613077" should have received an SMS including "did 1"
    When I go to the activity page
    Then I should see "Rule task 2"
    And I should see "Rule task 3"
    And I should see "Rule task 5"
    But I should not see "Rule task 1"
    And I should not see "Rule task 4"
    And I should not see "Rule task 6"
