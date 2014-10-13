Feature: User can credit another user who got them into the game

  Background: 
    Given the following demo exists:
      | name     | credit game referrer threshold | game referrer bonus | referred credit bonus | 
      | FooCorp  | 60                             | 5                   |                       |
      | QuuxCorp | 60                             | 10                  | 6                     |
    And the following users exist:
      | name | phone number | accepted invitation at | demo           | privacy level | notification method |
      | Phil | +14155551212 | 2011-05-01 12:00 EST   | name: FooCorp  | everybody     | email               |
      | Vlad | +16175551212 | 2011-05-01 11:59 EST   | name: FooCorp  | everybody     | email               |
      | Dan  | +18085551212 | 2011-05-01 12:00 EST   | name: FooCorp  | everybody     | both                |
      | Joe  | +17145551212 | 2011-05-01 12:00 EST   | name: QuuxCorp | everybody     | email               |
      | Fred | +14085551212 | 2011-05-01 12:00 EST   | name: QuuxCorp | everybody     | both                |
    And time is frozen at "2011-05-01 13:00 EST"
    And "Dan" has the password "foobar"
    And "Dan" has the SMS slug "dcroak"
    And "Vlad" has the SMS slug "vgyster"
    And "Phil" has the SMS slug "pdarnowsky"
    And "Fred" has the SMS slug "freddie"
    And "Fred" has the password "freddie"
    And I sign in via the login page with "Dan/foobar"

  Scenario: User credits another in a game with no referred credit bonus
    When "+14155551212" sends SMS "dcroak"
    And DJ works off
    And I go to the activity page
    # Then I should see "Dan 5 pts"
    And I should see "Dan got credit for recruiting Phil"
    And I should see "Phil credited Dan for recruiting them"
    And "+14155551212" should have received SMS "Got it, Dan recruited you. Thanks for letting us know."
    And "+18085551212" should have received an SMS including "Phil gave you credit for recruiting them. Many thanks and 5 bonus points!"

  Scenario: User credits another in a game with a referred credit bonus
    When "+17145551212" sends SMS "freddie"
    And DJ works off
    Then "+17145551212" should have received an SMS including "Got it, Fred recruited you. Thanks (and 6 points) for letting us know."
    And "+14085551212" should have received an SMS including "Joe gave you credit for recruiting them. Many thanks and 10 bonus points!"
    When I sign in via the login page with "Fred/freddie"
    Then I should see "Fred got credit for recruiting Joe"
    And I should see "Joe credited Fred for recruiting them"

  Scenario: User can't credit someone twice
    When "+14155551212" sends SMS "dcroak"
    And "+14155551212" sends SMS "vgyster"
    And I go to the activity page
    # Then I should see "Vlad 0 pts"
    And "+14155551212" should have received SMS "You've already told us that Dan recruited you."
    And "+16175551212" should not have received an SMS including "Phil gave you credit for recruiting them."

  Scenario: User tries to credit themself
    When "+14155551212" sends SMS "pdarnowsky"
    And I go to the activity page
    # Then I should see "Phil 0 pts"
    And "+14155551212" should have received an SMS "You've already claimed your account, and have 0 points. If you're trying to credit another user, text their Username"

  Scenario: User credits another but it's too late
    When "+16175551212" sends SMS "dcroak"
    And I go to the activity page
    # Then I should see "Dan 0 pts"
    And "+16175551212" should have received an SMS "Sorry, the time when you can credit someone for recruiting you is over."
    And "+18085551212" should not have received an SMS including "Vlad gave you credit"

  Scenario: User credits someone who doesn't exist
    When "+14155551212" sends SMS "jsmith"
    Then "+14155551212" should have received an SMS including "Sorry, I don't understand what "jsmith" means"

  Scenario: User credits another but the game's not set up for that
    Given the following demo exists:
      | name |
      | BarCorp      |
    And the following users exist:
      | name     | phone number | accepted invitation at | demo                  |
      | Kelli    | +13055551212 | 2011-05-01 12:00 EST   | name: BarCorp |
      | Kristina | +14105551212 | 2011-05-01 12:00 EST   | name: BarCorp |
    And "Kelli" has password "foobar"
    And "Kristina" has the SMS slug "krikantis"
    And "+13055551212" sends SMS "krikantis"
    And I sign in via the login page with "Kelli/foobar"
    # Then I should see "Kristina 0 pts"
    And "+13055551212" should have received an SMS including "Sorry, I don't understand what "krikantis" means"
    And "+14105551212" should not have received an SMS including "Kelli gave you credit"

  Scenario: User can't credit someone in a different demo
    When "+14155551212" sends SMS "freddie"
    Then "+14155551212" should have received an SMS including "Sorry, I don't understand what "freddie" means"
    And "+14085551212" should not have received any SMSes
