Feature: Admin moves a user to a new demo

  Background:
    Given time is frozen at "2010-05-01 12:00 EST"
    And the following demo exists:
      | company name    | victory threshold |
      | The Thoughtbots | 15                |
    And the following users exist:
      | name | points | recent_average_history_depth | recent_average_points |   demo                          | phone number |
      | Dan  | 0      | 1                            | 0                     |  company_name: The Thoughtbots | +14155551212 |
      | Bob  | 14     | 0                            | 8                     |  company_name: IBM             | +16175551212 |
      | Fred | 10     | 0                            | 11                    |  company_name: The Thoughtbots | +16175551213 |
      | Tom  | 5      | 0                            | 5                     |  company_name: IBM             | +14158675309 |
    And "Dan" has the password "foo"
    And "Bob" has the password "bar"
    And "Fred" has the password "baz"
    And "Tom" has the password "quux"
    And the following acts exist:
      | user       | text       | inherent points | created at           |
      | name: Dan  | ate banana | 7               | 2010-04-30 12:00 EST |
      | name: Dan  | walked dog | 9               |                      |
    And the following rule exists:
      | reply   | points | demo              |
      | run run | 10     | company_name: IBM |
    And the following rule values exists:
      | value        | rule           |
      | went running | reply: run run |
    And an admin moves "Dan" to the demo "IBM"
    And "+14155551212" sends SMS "went running"

  Scenario: User's new acts and ranking appear in the new demo
    And I sign in via the login page as "Bob/bar"
    And I go to the activity page
    Then I should see the following act:
      | name | act          | points |
      | Dan  | went running | 10     |
    And I should see "Dan" with ranking "2"

  Scenario: User's old acts don't appear in the new demo
    When I sign in via the login page as "Bob/bar"
    Then I should not see the following acts:
      | name | act        | points |
      | Dan  | ate banana | 7      |
      | Dan  | walked dog | 9      |

  Scenario: User's new acts and ranking don't appear in the old demo
    When I sign in via the login page as "Fred/baz"
    And I go to the activity page
    Then I should not see the following act:
      | name | act          | points |
      | Dan  | went running | 10     |
    And I should not see "Dan" in the scoreboard

  Scenario: In user's profile page, only new acts appear
    When I sign in via the login page as "Fred/baz"
    And I go to the profile page for "Dan"
    Then I should see the following act:
      | name | act          | points |
      | Dan  | went running | 10     |
    And I should not see the following acts:
      | name | act          | points |
      | Dan  | ate banana   | 7      |
      | Dan  | walked dog   | 9      |

  Scenario: User's old acts, correct score and ranking reappear when moved back to the original demo
    When an admin moves "Dan" to the demo "The Thoughtbots"
    And I sign in via the login page as "Fred/baz"
    And I go to the activity page
    Then I should see the following acts:
      | name | act        | points |
      | Dan  | ate banana | 7      |
      | Dan  | walked dog | 9      |
    And I should see "Dan" with ranking "1"

  Scenario: User disappears from view in the new demo when moved back to the original demo
    When an admin moves "Dan" to the demo "The Thoughtbots"
    And I sign in via the login page as "Bob/bar"
    And I go to the activity page
    Then I should not see the following act:
      | name | act          | points |
      | Dan  | went running | 10     |
    And I should not see "Dan" in the scoreboard

  Scenario: User has the correct recent average points and ranking after moving to new demo
    When I sign in via the login page as "Dan/foo"
    And I go to the activity page
    Then I should see "10" recent average points
    And I should see "1" recent average ranking

  Scenario: User has the correct recent average points and ranking after moving back to original demo
    When an admin moves "Dan" to the demo "The Thoughtbots"
    And I sign in via the login page as "Dan/foo"
    And I go to the activity page
    Then I should see "9" recent average points
    And I should see "2" recent average ranking

  Scenario: Other users' rankings are correct in the old demo after the move
    When I sign in via the login page as "Fred/baz"
    And I go to the activity page
    Then I should see "1 of 1" alltime ranking

  Scenario: Other users' rankings are correct in the new demo after moving back to the original demo
    When an admin moves "Dan" to the demo "The Thoughtbots"
    And I sign in via the login page as "Tom/quux"
    And I go to the activity page
    Then I should see "2 of 2" alltime ranking

  Scenario: "Won at" should be set appropriately per demo
    When I sign in via the login page as "Dan/foo"
    And I go to the activity page
    Then I should not see "You won at"
    When an admin moves "Dan" to the demo "The Thoughtbots"
    And I sign in via the login page as "Dan/foo"
    And I go to the activity page
    Then I should see "You won on May 01, 2010 at 01:00 PM Eastern"
