Feature: User completes suggested task

  Background:
    Given time is frozen at "2011-01-03 00:00 +0000"
    And the following demo exists:
      | company name |
      | TaskCo       |
    And the following claimed user exists:
      | name | phone number | demo                 |
      | Joe  | +14152613077 | company_name: TaskCo |
      | Bob  | +14155551212 | company_name: TaskCo |
    And "Bob" has the SMS slug "bob"
    And "Joe" has the password "foo"
    And the following suggested tasks exist:
      | name               | demo                 |
      | Rule task 1        | company_name: TaskCo |
      | Rule task 2        | company_name: TaskCo |
      | Rule task 3        | company_name: TaskCo |
      | Rule task 4        | company_name: TaskCo |
      | Rule task 5        | company_name: TaskCo |
      | Rule task 6        | company_name: TaskCo |
      | Referer task 1     | company_name: TaskCo |
      | Referer task 2     | company_name: TaskCo |
      | Survey task 1      | company_name: TaskCo |
      | Survey task 2      | company_name: TaskCo |
      | Survey task 3      | company_name: TaskCo |
      | Survey task 4      | company_name: TaskCo |
      | Demographic task 1 | company_name: TaskCo |
      | Demographic task 2 | company_name: TaskCo |
    And the following rules exist:
      | reply | demo                 |
      | did 1 | company_name: TaskCo |
      | did 5 | company_name: TaskCo |
    And the following rule value exists:
      | value | is primary | rule         |
      | do 1  | true       | reply: did 1 |
    And the following rule triggers exist:
      | rule         | suggested task    |
      | reply: did 1 | name: Rule task 1 |
      | reply: did 5 | name: Rule task 5 |
    And the following rule triggers exist:
      | rule         | suggested task       | referrer required |
      | reply: did 1 | name: Referer task 1 | true              |
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
    And the following demographic triggers exist:
      | suggested task           |
      | name: Demographic task 1 |
    And the task "Rule task 2" has prerequisite "Rule task 1"
    And the task "Rule task 4" has prerequisite "Rule task 3"
    And the task "Rule task 6" has prerequisite "Rule task 5"
    And the task "Survey task 2" has prerequisite "Survey task 1"
    And the task "Survey task 4" has prerequisite "Survey task 2"
    And the task "Referer task 2" has prerequisite "Referer task 1"
    And the task "Demographic task 2" has prerequisite "Demographic task 1"
    And DJ cranks 30 times
    When I sign in via the login page with "Joe/foo"

    Then I should see "Rule task 1"
    And I should see "Rule task 3"
    And I should see "Rule task 5"
    And I should see "Survey task 1"
    And I should see "Survey task 3"
    And I should see "Referer task 1"
    And I should see "Demographic task 1"

    But I should not see "Rule task 2"
    And I should not see "Rule task 4"
    And I should not see "Rule task 6"
    And I should not see "Survey task 2"
    And I should not see "Survey task 4"
    And I should not see "Referer task 2"
    And I should not see "Demographic task 2"
    And I should not see "I completed a daily dose!"

  Scenario: User completes suggested task by acting according to rule
    When "+14152613077" sends SMS "do 1"
    Then "+14152613077" should have received an SMS including "did 1"
    When I go to the activity page

    Then I should see "Rule task 2"
    And I should see "Rule task 3"
    And I should see "Rule task 5"
    And I should see "Survey task 1"
    And I should see "Survey task 3"
    And I should see "Referer task 1"
    And I should see "Demographic task 1"
    And I should see "I completed a daily dose!"

    But I should not see "Rule task 1"
    And I should not see "Rule task 4"
    And I should not see "Rule task 6"
    And I should not see "Survey task 2"
    And I should not see "Survey task 4"
    And I should not see "Referer task 2"
    And I should not see "Demographic task 2"

    When DJ cranks 5 times after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a daily dose."

  Scenario: User completes suggested task by acting according to rule with mandatory referrer
    When "+14152613077" sends SMS "do 1 bob"
    Then "+14152613077" should have received an SMS including "did 1"
    When I go to the activity page

    Then I should see "Rule task 2"
    And I should see "Rule task 3"
    And I should see "Rule task 5"
    And I should see "Survey task 1"
    And I should see "Survey task 3"
    And I should see "Referer task 2"
    And I should see "Demographic task 1"
    And I should see "I completed a daily dose!"

    But I should not see "Rule task 1"
    And I should not see "Rule task 4"
    And I should not see "Rule task 6"
    And I should not see "Survey task 2"
    And I should not see "Survey task 4"
    And I should not see "Referer task 1"
    And I should not see "Demographic task 2"

    When DJ cranks 10 times after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a daily dose."

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
    And I should see "Referer task 1"
    And I should see "Demographic task 1"
    And I should see "I completed a daily dose!"

    But I should not see "Rule task 2"
    And I should not see "Rule task 4"
    And I should not see "Rule task 6"
    And I should not see "Survey task 1"
    And I should not see "Survey task 4"
    And I should not see "Referer task 2"
    And I should not see "Demographic task 2"

    When DJ cranks 5 times after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a daily dose."

  Scenario: User completes demographic task by filling in their details
    When I go to the profile page for "Joe"
    And I fill in "Weight (in pounds)" with "230"
    And I select "6" from "Feet"
    And I select "3" from "Inches"
    And I select "Male" from "Gender"
    And I press the button to update demographic information
    And I go to the activity page
    Then I should see "Demographic task 1"
    But I should not see "Demographic task 2"
    And I should not see "I completed a daily dose!"

    When I go to the profile page for "Joe"
    And I select "1977-09-10" as the "Date of birth" date
    And I press the button to update demographic information
    And I go to the activity page

    Then I should see "Rule task 1"
    And I should see "Rule task 3"
    And I should see "Rule task 5"
    And I should see "Survey task 1"
    And I should see "Survey task 3"
    And I should see "Referer task 1"
    And I should see "Demographic task 2"
    And I should see "I completed a daily dose!"

    But I should not see "Rule task 2"
    And I should not see "Rule task 4"
    And I should not see "Rule task 6"
    And I should not see "Survey task 2"
    And I should not see "Survey task 4"
    And I should not see "Referer task 2"
    And I should not see "Demographic task 1"

    When DJ cranks 5 times after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a daily dose."
