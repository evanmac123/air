Feature: Game has a beginning and an end
  Background:
    Given the following demo exists:
      | company name | begins at               | ends at                 |
      | BarInc       | 2010-04-01 12:00:00 UTC | 2010-05-01 12:00:00 UTC |
    And the following users exist:
      | name | phone number | demo                 |
      | Phil | +14152613077 | company_name: BarInc |
      | Vlad | +16175551212 | company_name: BarInc |
    And the following accepted friendships exist:
      | user        | friend     |
      | name: Vlad  | name: Phil |
    And the following rules exist:
      | reply          | points | demo                 | 
      | You ate fruit. | 2      | company_name: BarInc | 
      | Worked out.    | 3      | company_name: BarInc | 
    And the following rule values exist:
      | value      | rule                  |
      | ate fruit  | reply: You ate fruit. |
      | went gym   | reply: Worked out.    |
    And "Phil" has the password "foo"
    And "Vlad" has the SMS slug "vgyster"
    And I sign in via the login page with "Phil/foo"

  Scenario: Sending actions before the game begins
    When time is frozen at "2010-04-01 11:59:59 UTC"
    And "+14152613077" sends SMS "ate fruit"
    And time is frozen at "2010-04-01 12:00:00 UTC"
    And "+14152613077" sends SMS "went gym"
    Then "+14152613077" should have received an SMS "Worked out. Rank 1/2."
    And "+14152613077" should not have received an SMS "You ate fruit. Rank 1/2."
    And "+14152613077" should have received an SMS "The game will begin April 01, 2010 at 08:00 AM Eastern. Please try again after that time."

  Scenario: Sending actions after the game ends
    When time is frozen at "2010-05-01 12:00:00 UTC"
    And "+14152613077" sends SMS "ate fruit"
    And time is frozen at "2010-05-01 12:00:01 UTC"
    And "+14152613077" sends SMS "went gym"
    Then "+14152613077" should have received an SMS "You ate fruit. Rank 1/2."
    And "+14152613077" should not have received an SMS "Worked out. Rank 1/2."
    And "+14152613077" should have received an SMS "Thanks for playing! The game is now over. If you'd like more information e-mailed to you, please text MORE INFO."

  Scenario: Following before the game begins via site does nothing
    Given time is frozen at "2010-04-01 11:59:59 UTC"
    Then "Phil" should not be able to follow "Vlad"

  Scenario: Before the game begins friending buttons are disabled
    Given time is frozen at "2010-04-01 11:59:59 UTC"
    Then all follow buttons for "Vlad" should be disabled

  Scenario: Following after the game ends via site does nothing
    Given time is frozen at "2010-05-01 12:00:01 UTC"
    Then "Phil" should not be able to follow "Vlad"

  Scenario: After the game ends friending buttons are disabled
    Given time is frozen at "2010-05-01 12:00:01 UTC"
    Then all follow buttons for "Vlad" should be disabled

  Scenario: Following before the game begins via SMS does nothing
    Given time is frozen at "2010-04-01 11:59:59 UTC"
    When "+14152613077" sends SMS "follow vgyster"
    And I go to the activity page
    Then I should not see "Phil is now a fan of Vlad"
    And "+14152613077" should have received an SMS including "Please try again after that time."

  Scenario: Following after the game ends via SMS does nothing
    Given time is frozen at "2010-05-01 12:00:01 UTC"
    When "+14152613077" sends SMS "follow vgyster"
    And I go to the activity page
    Then I should not see "Phil is now a fan of Vlad"
    And "+14152613077" should have received an SMS including "The game is now over"
