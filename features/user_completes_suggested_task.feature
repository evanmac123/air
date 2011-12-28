Feature: User completes suggested task

  Background:
    Given time is frozen at "2011-01-03 00:00 +0000"
    And the following demo exists:
      | company name |
      | TaskCo       |
    And the following claimed user exists:
      | name | phone number | demo                 |
      | Joe  | +14152613077 | company_name: TaskCo |
    And "Joe" has the password "foo"
    And the following suggested tasks exist:
      | name          | demo                 |
      | Rule task 1   | company_name: TaskCo |
      | Rule task 2   | company_name: TaskCo |
      | Rule task 3   | company_name: TaskCo |
      | Rule task 4   | company_name: TaskCo |
      | Rule task 5   | company_name: TaskCo |
      | Rule task 6   | company_name: TaskCo |
      | Survey task 1 | company_name: TaskCo |
      | Survey task 2 | company_name: TaskCo |
      | Survey task 3 | company_name: TaskCo |
      | Survey task 4 | company_name: TaskCo |
    And the following rules exist:
      | reply | demo                 |
      | did 1 | company_name: TaskCo |
    And the following rule value exists:
      | value | is primary | rule         |
      | do 1  | true       | reply: did 1 |
    And the following rule triggers exist:
      | rule         | suggested task    |
      | reply: did 1 | name: Rule task 1 |
      | reply: did 5 | name: Rule task 5 |
    And the following survey exists:
      | name     | demo                 | open at                | close at               |
      | Survey 1 | company_name: TaskCo | 2011-01-01 00:00 +0000 | 2011-01-05 00:00 +0000 |
      | Survey 2 | company_name: TaskCo | 2012-01-01 00:00 +0000 | 2012-01-05 00:00 +0000 |
    And the following survey questions exist:
      | text  | index | survey         |
      | Q 1-1 | 1     | name: Survey 1 |
      | Q 1-2 | 2     | name: Survey 1 |
      | Q 1-3 | 3     | name: Survey 1 |
      | Q 2-1 | 1     | name: Survey 2 |
      | Q 2-2 | 2     | name: Survey 2 |
      | Q 2-3 | 3     | name: Survey 2 |
    And the following survey valid answers exist:
      | value | survey question |
      | 1     | text: Q 1-1     |
      | 2     | text: Q 1-1     |
      | 1     | text: Q 1-2     |
      | 2     | text: Q 1-2     |
      | 1     | text: Q 1-3     |
      | 2     | text: Q 1-3     |
      | 1     | text: Q 2-1     |
      | 2     | text: Q 2-1     |
      | 1     | text: Q 2-2     |
      | 2     | text: Q 2-2     |
      | 1     | text: Q 2-3     |
      | 2     | text: Q 2-3     |
    And the following survey triggers exist:
      | survey         | suggested task      |
      | name: Survey 1 | name: Survey task 1 |
      | name: Survey 2 | name: Survey task 3 |
    And the task "Rule task 2" has prerequisite "Rule task 1"
    And the task "Rule task 4" has prerequisite "Rule task 3"
    And the task "Rule task 6" has prerequisite "Rule task 5"
    And the task "Survey task 2" has prerequisite "Survey task 1"
    And the task "Survey task 4" has prerequisite "Survey task 2"
    And DJ cranks 20 times
    When I sign in via the login page with "Joe/foo"

    Then I should see "Rule task 1"
    And I should see "Rule task 3"
    And I should see "Rule task 5"
    And I should see "Survey task 1"
    And I should see "Survey task 3"

    But I should not see "Rule task 2"
    And I should not see "Rule task 4"
    And I should not see "Rule task 6"
    And I should not see "Survey task 2"
    And I should not see "Survey task 4"

  Scenario: User completes suggested task by acting according to rule
    When "+14152613077" sends SMS "do 1"
    Then "+14152613077" should have received an SMS including "did 1"
    When I go to the activity page

    Then I should see "Rule task 2"
    And I should see "Rule task 3"
    And I should see "Rule task 5"
    And I should see "Survey task 1"
    And I should see "Survey task 3"

    But I should not see "Rule task 1"
    And I should not see "Rule task 4"
    And I should not see "Rule task 6"
    And I should not see "Survey task 2"
    And I should not see "Survey task 4"

  Scenario: User completes suggested task by completing survey
    When "+14152613077" sends SMS "survey"
    And "+14152613077" sends SMS "1"
    And "+14152613077" sends SMS "1"
    And "+14152613077" sends SMS "1"
    Then "+14152613077" should have received an SMS including "Thanks for completing the survey"
    When I go to the activity page

    Then I should see "Rule task 1"
    And I should see "Rule task 3"
    And I should see "Rule task 5"
    And I should see "Survey task 2"
    And I should see "Survey task 3"

    But I should not see "Rule task 2"
    And I should not see "Rule task 4"
    And I should not see "Rule task 6"
    And I should not see "Survey task 1"
    And I should not see "Survey task 4"

