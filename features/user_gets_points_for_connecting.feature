Feature: User gets points for connecting to another (if demo configured for it)

  Background:
    Given the following demos exists:
      | company name  | points for connecting |
      | HMFEngage     | 5                     |
      | Towers Watson | 0                     |
      | LameCo        |                       |
    And the following users exist:
      | name | phone number | connection bounty | demo                        |
      | Dan  | +14155551212 | 0                 | company_name: HMFEngage     |
      | Phil | +18085551212 | 7                 | company_name: HMFEngage     |
      | Vlad | +16175551212 | 0                 | company_name: HMFEngage     |
      | Tom  | +13055551212 | 0                 | company_name: Towers Watson |
      | Fred | +12125551212 | 7                 | company_name: Towers Watson |
      | Bleh | +14085551212 | 0                 | company_name: LameCo        |
      | Feh  | +16505551212 | 7                 | company_name: LameCo        |
    And "Dan" has password "foo"
    When I sign in via the login page as "Dan/foo"

  Scenario: User gets points for connecting
    When I go to the profile page for "Vlad"
    And I press "Be a fan"
    And I go to the activity page
    Then I should see "Dan is now a fan of Vlad"
    And I should see "5 points"

  Scenario: User gets extra points for connection to a user with a bounty
    When I go to the profile page for "Phil"
    And I press "Be a fan"
    And I go to the activity page
    Then I should see "Dan is now a fan of Phil"
    And I should see "12 points"

  Scenario: User gets points for connecting just once
    When I go to the profile page for "Vlad"
    And I press "Be a fan"
    And I press "De-fan"
    And I press "Be a fan"
    And I go to the activity page
    Then I should see "5 points" just once

  Scenario: User gets message for connecting to a user with a bounty when demo has bounty
    When "+14155551212" sends SMS "follow pphil"
    Then "+14155551212" should have received SMS "OK, you're now following Phil. You've collected 5 bonus points for the connection, plus another 7 bonus points."

  Scenario: User gets message for connecting to a user with 0 bounty when demo has bounty
    When "+18085551212" sends SMS "follow ddan"
    Then "+18085551212" should have received SMS "OK, you're now following Dan. You've collected 5 bonus points for the connection."

  Scenario: User gets message for connecting to a user with bounty when demo has 0 bounty
    When "+13055551212" sends SMS "follow ffred"
    Then "+13055551212" should have received SMS "OK, you're now following Fred. You've collected 7 bonus points for the connection."

  Scenario: User gets message for connecting to a user with 0 bounty when demo has 0 bounty
    When "+12125551212" sends SMS "follow ttom"
    Then "+12125551212" should have received SMS "OK, you're now following Tom."

  Scenario: User gets message for connecting to a user with bounty when demo has no bounty
    When "+16505551212" sends SMS "follow bbleh"
    Then "+16505551212" should have received SMS "OK, you're now following Bleh."

  Scenario: User gets message for connecting to a user with 0 bounty when demo has no bounty
    When "+14085551212" sends SMS "follow ffeh"
    Then "+14085551212" should have received SMS "OK, you're now following Feh."
