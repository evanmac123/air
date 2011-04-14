Feature: Game has an end

  Scenario: Sending actions after the game ends
    Given the following demo exists:
      | company name | ends at                 |
      | BarInc       | 2010-05-01 12:00:00 UTC |
    And the following user exists:
      | phone number | demo                 |
      | +14152613077 | company_name: BarInc |
    And the following rules exist:
      | value      | reply          | points |
      | ate fruit  | You ate fruit. | 2      |
      | went gym   | Worked out.    | 3      |
    When time is frozen at "2010-05-01 11:59:59 UTC"
    And "+14152613077" sends SMS "ate fruit"
    And time is frozen at "2010-05-01 12:00:00 UTC"
    And "+14152613077" sends SMS "went gym"
    Then "+14152613077" should have received an SMS "You ate fruit. Rank 1/1."
    And "+14152613077" should not have received an SMS "Worked out. Rank 1/1."
    And "+14152613077" should have received an SMS "Thanks for playing! The game is now over. If you'd like more information e-mailed to you, please text MORE INFO."
