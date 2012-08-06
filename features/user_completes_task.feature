Feature: User completes task

  Background:
    Given the following demo exists:
      | name   |
      | TaskCo |
    And the following claimed user exists:
      | name | phone number | email           | demo         |
      | Joe  | +14152613077 | joe@example.com | name: TaskCo |
      | Bob  | +14155551212 | bob@example.com | name: TaskCo |
    And "Bob" has the SMS slug "bob"
    And "Bob" has the password "foobar"
    And "Joe" has the password "foobar"
    And the following tasks exist:
      | name               | demo         |
      | Rule task 1        | name: TaskCo |
      | Rule task 2        | name: TaskCo |
      | Rule task 3        | name: TaskCo |
      | Rule task 4        | name: TaskCo |
      | Rule task 5        | name: TaskCo |
      | Rule task 6        | name: TaskCo |
      | Referer task 1     | name: TaskCo |
      | Referer task 2     | name: TaskCo |
      | Survey task 1      | name: TaskCo |
      | Survey task 2      | name: TaskCo |
      | Survey task 3      | name: TaskCo |
      | Survey task 4      | name: TaskCo |
      | Demographic task 1 | name: TaskCo |
      | Demographic task 2 | name: TaskCo |
    And the following rules exist:
      | reply | demo         |
      | did 1 | name: TaskCo |
      | did 5 | name: TaskCo |
    And the following rule value exists:
      | value | is primary | rule         |
      | do 1  | true       | reply: did 1 |
    And the following rule triggers exist:
      | rule         | task    |
      | reply: did 1 | name: Rule task 1 |
      | reply: did 5 | name: Rule task 5 |
    And the following rule triggers exist:
      | rule         | task       | referrer required |
      | reply: did 1 | name: Referer task 1 | true              |
    And demo "TaskCo" open survey with name "Survey 1" exists
    And demo "TaskCo" survey with name "Survey 2" exists
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
      | survey         | task      |
      | name: Survey 1 | name: Survey task 1 |
      | name: Survey 2 | name: Survey task 3 |
    And the following demographic triggers exist:
      | task           |
      | name: Demographic task 1 |
    And the task "Rule task 2" has prerequisite "Rule task 1"
    And the task "Rule task 4" has prerequisite "Rule task 3"
    And the task "Rule task 6" has prerequisite "Rule task 5"
    And the task "Survey task 2" has prerequisite "Survey task 1"
    And the task "Survey task 4" has prerequisite "Survey task 2"
    And the task "Referer task 2" has prerequisite "Referer task 1"
    And the task "Demographic task 2" has prerequisite "Demographic task 1"
    And DJ works off
    When I sign in via the login page with "Joe/foobar"

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

  @javascript
  Scenario: User completes task by acting according to rule
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

    When DJ works off after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a daily dose."

  Scenario: User completes rule task by SMS and gets congrats by SMS
    Given a clear email queue
    When "+14152613077" sends SMS "do 1"
    When DJ works off after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a daily dose."
    But "joe@example.com" should receive no email

  Scenario: User completes rule task by email and gets congrats by email
    When "joe@example.com" sends email with subject "do 1" and body "do 1"
    And DJ works off after a little while
    Then "+14152613077" should not have received any SMSes
    But "joe@example.com" should receive an email with "Congratulations! You've completed a daily dose." in the email body

  Scenario: User completes rule task on web and sees congrats in the flash
    When I sign in via the login page with "Joe/foobar" and choose to be remembered
    Given a clear email queue
    When I enter the act code "do 1"
    And DJ works off after a little while
    Then "+14152613077" should not have received any SMSes
    And "joe@example.com" should receive no email
    But I should see "Congratulations! You've completed a daily dose."
    When I go to the activity page
    Then I should not see "Your session has expired"

  @javascript
  Scenario: User completes task by acting according to rule with mandatory referrer
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

    When DJ works off after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a daily dose."

  @javascript
  Scenario: User completes task by completing survey
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

    When DJ works off after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a daily dose."

  @javascript
  Scenario: User completes demographic task by filling in their details
    When I go to the settings page
    And I fill in most of my demographic information
    And I press the button to save the user's settings
    And I go to the activity page
    Then I should see "Demographic task 1"
    But I should not see "Demographic task 2"
    And I should not see "I completed a daily dose!"

    When I go to the settings page
    And I fill in "Date of Birth" with "September 10, 1977"
    And I press the button to save the user's settings
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

    When DJ works off after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a daily dose."  
  
  Scenario: User completes survey task by SMS and gets congrats by SMS
    Given a clear email queue
    When "+14152613077" sends SMS "1"
    And "+14152613077" sends SMS "1"
    And "+14152613077" sends SMS "1"
    When DJ works off after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a daily dose."
    But "joe@example.com" should receive no email

  Scenario: User completes survey task by email and gets congrats by email
    When "joe@example.com" sends email with subject "1" and body "1"
    When "joe@example.com" sends email with subject "1" and body "1"
    When "joe@example.com" sends email with subject "1" and body "1"
    Then "+14152613077" should not have received any SMSes
    But "joe@example.com" should receive an email with "Congratulations! You've completed a daily dose." in the email body

  Scenario: User completes survey task on web and sees congrats in the flash
    When I sign in via the login page with "Joe/foobar"
    And I enter the act code "1"
    And I enter the act code "1"
    And I enter the act code "1"
    When DJ works off after a little while
    Then "+14152613077" should not have received any SMSes
    And "joe@example.com" should receive no email
    But I should see "Congratulations! You've completed a daily dose."
