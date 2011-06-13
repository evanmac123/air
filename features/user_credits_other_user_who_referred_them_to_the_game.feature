Feature: User can credit another user who got them into the game

  Background: 
    Given the following demo exists:
      | company name | credit game referrer threshold | game referrer bonus |
      | FooCorp      | 60                             | 5                   |
    And the following users exist:
      | name | phone number | accepted invitation at | demo                  |
      | Phil | +14155551212 | 2011-05-01 12:00 EST   | company_name: FooCorp |
      | Vlad | +16175551212 | 2011-05-01 11:59 EST   | company_name: FooCorp |
      | Dan  | +18085551212 | 2011-05-01 12:00 EST   | company_name: FooCorp |
    And the following rule exists:
      | reply  | points | demo                  |
      | kitten | 5      | company_name: FooCorp |
    And the following primary value exists:
      | value      | rule          |
      | ate kitten | reply: kitten |
    And time is frozen at "2011-05-01 13:00 EST"
    And "Dan" has the password "foo"
    And "Dan" has the SMS slug "dcroak"
    And "Vlad" has the SMS slug "vgyster"
    And "Phil" has the SMS slug "pdarnowsky"
    And I sign in via the login page with "Dan/foo"

  Scenario: User credits another
    When "+14155551212" sends SMS "dcroak"
    And I go to the activity page
    Then I should see "Dan 5 points"
    And I should see "Dan got credit for referring Phil to the game"
    And "+14155551212" should have received SMS "Got it, Dan referred you to the game. Thanks for letting us know."
    And "+18085551212" should have received an SMS including "Phil gave you credit for referring him to the game. Many thanks and 5 bonus points!"
    
  Scenario: User can't credit someone twice
    When "+14155551212" sends SMS "dcroak"
    And "+14155551212" sends SMS "vgyster"
    And I go to the activity page
    Then I should see "Vlad 0 points"
    And "+14155551212" should have received SMS "You've already told us that Dan referred you to the game."
    And "+16175551212" should not have received an SMS including "Phil gave you credit for referring him to the game."

  Scenario: User tries to credit themself
    When "+14155551212" sends SMS "pdarnowsky"
    And I go to the activity page
    Then I should see "Phil 0 points"
    And "+14155551212" should have received an SMS "Nice try. But would it be fair to give you points for referring yourself?"

  Scenario: User credits another but it's too late
    When "+16175551212" sends SMS "dcroak"
    And I go to the activity page
    Then I should see "Dan 0 points"
    And "+16175551212" should have received an SMS "Sorry, the time when you can credit someone for referring you to the game is over."
    And "+18085551212" should not have received an SMS including "Vlad gave you credit"

  Scenario: User credits someone who doesn't exist
    When "+14155551212" sends SMS "jsmith"
    Then "+14155551212" should have received an SMS including "Sorry, I don't understand what that means"

  Scenario: User credits another but the game's not set up for that
    Given the following demo exists:
      | company name |
      | BarCorp      |
    And the following users exist:
      | name     | phone number | accepted invitation at | demo                  |
      | Kelli    | +13055551212 | 2011-05-01 12:00 EST   | company_name: BarCorp |
      | Kristina | +14105551212 | 2011-05-01 12:00 EST   | company_name: BarCorp |
    And "Kelli" has password "foo"
    And "Kristina" has the SMS slug "krikantis"
    And "+13055551212" sends SMS "krikantis"
    And I sign in via the login page with "Kelli/foo"
    Then I should see "Kristina 0 points"
    And "+13055551212" should have received an SMS including "Sorry, I don't understand what that means"
    And "+14105551212" should not have received an SMS including "Kelli gave you credit"

  Scenario: User sends valid rule during their credit period
    Given "+14155551212" sends SMS "ate kitten"
    Then "+14155551212" should have received an SMS including "kitten"

  Scenario: User sends valid rule after their credit period
    Given "+16175551212" sends SMS "ate kitten"
    Then "+16175551212" should have received an SMS including "kitten"

  Scenario: User sends invalid rule during their credit period
    Given "+14155551212" sends SMS "ate pizza"
    Then "+14155551212" should have received an SMS including "ate kitten"

  Scenario: User sends invalid rule after their credit period
    Given "+16175551212" sends SMS "ate pizza"
    Then "+16175551212" should have received an SMS including "ate kitten"

