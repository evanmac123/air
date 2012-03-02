Feature: Admin moves a user to a new demo

  Background:
    Given time is frozen at "2010-05-01 12:00 EST"
    And the following demo exists:
      | name    | victory threshold |
      | The Thoughtbots | 15                |
    And the following claimed users exist:
      | name | points | recent_average_history_depth | recent_average_points | privacy level | demo                  | phone number |
      | Dan  | 0      | 1                            | 0                     | everybody     | name: The Thoughtbots | +14155551212 |
      | Bob  | 14     | 0                            | 8                     | everybody     | name: IBM             | +16175551212 |
      | Fred | 10     | 0                            | 11                    | everybody     | name: The Thoughtbots | +16175551213 |
      | Tom  | 5      | 0                            | 5                     | everybody     | name: IBM             | +14158675309 |
    And "Dan" has the password "fooish"
    And "Bob" has the password "barfing"
    And "Fred" has the password "bazlet"
    And "Tom" has the password "quuxberg"
    And the following acts exist:
      | user       | text       | inherent points | created at           |
      | name: Dan  | ate banana | 7               | 2010-04-30 12:00 EST |
      | name: Dan  | walked dog | 9               |                      |
    And the following rule exists:
      | reply   | points | demo              |
      | run run | 10     | name: IBM |
    And the following rule values exists:
      | value        | rule           |
      | went running | reply: run run |
    And the following levels exist:
      | name        | demo                          |
      | AwesomeStar | name: The Thoughtbots |
      | Some Pig!   | name: The Thoughtbots |
    And "Dan" has level "AwesomeStar"
    And "Dan" has level "Some Pig!"
    And an admin moves "Dan" to the demo "IBM"
    And "+14155551212" sends SMS "went running"

  Scenario: User's new acts appear in the new demo
    And I sign in via the login page as "Bob/barfing"
    And I go to the activity page
    Then I should see the following act:
      | name | act          | points |
      | Dan  | went running | 10     |

  Scenario: User's old acts don't appear in the new demo
    When I sign in via the login page as "Bob/barfing"
    Then I should not see the following acts:
      | name | act        | points |
      | Dan  | ate banana | 7      |
      | Dan  | walked dog | 9      |

  Scenario: User's new acts don't appear in the old demo
    When I sign in via the login page as "Fred/bazlet"
    And I go to the activity page
    Then I should not see the following act:
      | name | act          | points |
      | Dan  | went running | 10     |

  Scenario: In user's profile page, only new acts appear
    When I sign in via the login page as "Bob/barfing"
    And I go to the profile page for "Dan"
    Then I should be on the profile page for "Dan"
    
    Then I should see the following act:
      | name | act          | points |
      | Dan  | went running | 10     |
    And I should not see the following acts:
      | name | act          | points |
      | Dan  | ate banana   | 7      |
      | Dan  | walked dog   | 9      |

  Scenario: User's old acts reappear when moved back to the original demo
    When an admin moves "Dan" to the demo "The Thoughtbots"
    And I sign in via the login page as "Fred/bazlet"
    And I go to the activity page
    Then I should see the following acts:
      | name | act        | points |
      | Dan  | ate banana | 7      |
      | Dan  | walked dog | 9      |

#   Scenario: User's achievements appear only in the appropriate demo
    # When I sign in via the login page as "Dan/fooish"
    # Then I should not see "AwesomeStar"
    # And I should not see "Some Pig!"
    # When an admin moves "Dan" to the demo "The Thoughtbots"
    # And I sign in via the login page as "Dan/fooish"
    # Then I should see "AwesomeStar"
#     And I should see "Some Pig!"

  Scenario: User disappears from view in the new demo when moved back to the original demo
    When an admin moves "Dan" to the demo "The Thoughtbots"
    And I sign in via the login page as "Bob/barfing"
    And I go to the activity page
    Then I should not see the following act:
      | name | act          | points |
      | Dan  | went running | 10     |

#   Scenario: Other users' rankings are correct in the old demo after the move
    # When I sign in via the login page as "Fred/bazlet"
    # And I go to the activity page
    # Then I should see "1st out of 1" ranking

  # Scenario: Other users' rankings are correct in the new demo after moving back to the original demo
    # When an admin moves "Dan" to the demo "The Thoughtbots"
    # And I sign in via the login page as "Tom/quuxberg"
    # And I go to the activity page
    # Then I should see "2nd out of 2" ranking

  # Scenario: "Won at" should be set appropriately per demo
    # When I sign in via the login page as "Dan/fooish"
    # And I go to the activity page
    # Then I should not see "You won at"
    # When an admin moves "Dan" to the demo "The Thoughtbots"
    # And I sign in via the login page as "Dan/fooish"
    # And I go to the activity page
    # Then I should see "You won on May 01, 2010 at 01:00 PM Eastern"
