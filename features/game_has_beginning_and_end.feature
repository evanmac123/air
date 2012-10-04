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

  Scenario: Sending actions before the game begins
    When time is frozen at "2010-04-01 11:59:59 UTC"
    And "+14152613077" sends SMS "ate fruit"
    And time is frozen at "2010-04-01 12:00:00 UTC"
    And "+14152613077" sends SMS "went gym"
    And I dump all sent texts
    Then "+14152613077" should have received an SMS "Worked out. Points 3, level 1."
    And "+14152613077" should not have received an SMS including "You ate fruit."
    And "+14152613077" should have received an SMS "The game will begin April 01, 2010 at 08:00 AM Eastern. Please try again after that time."

  Scenario: Sending actions after the game ends
    When time is frozen at "2010-05-01 12:00:00 UTC"
    And "+14152613077" sends SMS "ate fruit"
    And time is frozen at "2010-05-01 12:00:01 UTC"
    And "+14152613077" sends SMS "went gym"
    Then "+14152613077" should have received an SMS "You ate fruit. Points 2, level 1."
    And "+14152613077" should not have received an SMS including "Worked out."
    And "+14152613077" should have received an SMS "Thanks for playing! The game is now over. If you'd like more information e-mailed to you, please text INFO."

  Scenario: Sending actions outside of game window with custom messages
    When time is frozen at "2010-04-01 11:59:59 UTC"
    And "+18085551212" sends SMS "customs"
    And time is frozen at "2010-05-01 12:00:01 UTC"
    And "+18085551212" sends SMS "customs"
    Then "+18085551212" should not have received an SMS including "Did customs"
    And "+18085551212" should have received an SMS "Hold ur horses"
    And "+18085551212" should have received an SMS "Too slow!"

  @javascript
  Scenario: Following after the game ends via site does nothing
    When I sign in via the login page as "Phil/foobar" and choose to be remembered
    And I go to the profile page for "Vlad"
    And time is frozen at "2010-05-01 12:00:01 UTC"
    And I press the befriend button for "Vlad"
    And DJ cranks 5 times
    Then "+16175551212" should not have received any SMSes
    And time is unfrozen
    And I should see "Thanks for playing! The game is now over."

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
    And "+14152613077" should have received an SMS including "The game is now over"
