Feature: Game has a beginning and an end
  Background:
    Given the following demo exists:
      | name | begins at               | ends at                 |
      | BarInc       | 2010-04-01 12:00:00 UTC | 2010-05-01 12:00:00 UTC |
    And the following demo exists:
      | name     | begins at               | ends at                 | act too early message | act too late message | 
      | CustomCo | 2010-04-01 12:00:00 UTC | 2010-05-01 12:00:00 UTC | Hold ur horses        | Too slow!            |
    And the following claimed users exist:
      | name | phone number | demo           |
      | Phil | +14152613077 | name: BarInc   |
      | Vlad | +16175551212 | name: BarInc   |
      | Bob  | +18085551212 | name: CustomCo |
    And the following accepted friendships exist:
      | user        | friend     |
      | name: Vlad  | name: Phil |
    And the following rules exist:
      | reply          | points | demo           | 
      | You ate fruit. | 2      | name: BarInc   | 
      | Worked out.    | 3      | name: BarInc   | 
      | Did customs    | 10     | name: CustomCo |
    And the following rule values exist:
      | value      | rule                  |
      | ate fruit  | reply: You ate fruit. |
      | went gym   | reply: Worked out.    |
      | customs    | reply: Did customs    |
    And "Phil" has the password "foobar"
    And "Vlad" has the SMS slug "vgyster"
    And I sign in via the login page with "Phil/foobar"

  @javascript
  Scenario: Following after the game ends via site does nothing
    When I sign in via the login page as "Phil/foobar" and choose to be remembered
    And I go to the profile page for "Vlad"
    And time is frozen at "2010-05-01 12:00:01 UTC"
    And I press the befriend button for "Vlad"
    And DJ cranks 5 times
    Then "+16175551212" should not have received any SMSes
    And time is unfrozen
    And I should see "Thanks for participating. Your administrator has disabled this board."

  Scenario: Following before the game begins via SMS does nothing
    Given time is frozen at "2010-04-01 11:59:59 UTC"
    When "+14152613077" sends SMS "follow vgyster"
    And I go to the activity page
    Then I should not see "Phil is now friends with Vlad"
    And "+14152613077" should have received an SMS including "Please try again after that time."

  Scenario: Following after the game ends via SMS does nothing
    Given time is frozen at "2010-05-01 12:00:01 UTC"
    When "+14152613077" sends SMS "follow vgyster"
    And I go to the activity page
    Then I should not see "Phil is now friends with Vlad"
    And "+14152613077" should have received an SMS including "Your administrator has disabled this board"
