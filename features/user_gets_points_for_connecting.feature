Feature: User gets points for connecting to another (if demo configured for it)

  Background:
    Given the following demos exists:
      | name          | points for connecting |
      | HMFEngage     | 5                     |
      | Towers Watson | 0                     |
      | LameCo        |                       |
    And the following claimed users exist:
      | name | phone number | connection bounty | points | privacy level | demo                |
      | Dan  | +14155551212 | 0                 | 1      | everybody     | name: HMFEngage     |
      | Phil | +18085551212 | 7                 | 0      | everybody     | name: HMFEngage     |
      | Vlad | +16175551212 | 0                 | 0      | everybody     | name: HMFEngage     |
      | Tom  | +13055551212 | 0                 | 0      | everybody     | name: Towers Watson |
      | Fred | +12125551212 | 7                 | 0      | everybody     | name: Towers Watson |
      | Bleh | +14085551212 | 0                 | 0      | everybody     | name: LameCo        |
      | Feh  | +16505551212 | 7                 | 0      | everybody     | name: LameCo        |
    And "Dan" has password "foobar"
    And "Vlad" has the SMS slug "vlad"
    And "Phil" has the SMS slug "phil"
    When I sign in via the login page as "Dan/foobar"

  Scenario: User gets points for connecting
    When "+14155551212" sends SMS "follow vlad"
    And "+16175551212" sends SMS "yes"
    And I go to the activity page
    Then I should see "Dan is now a fan of Vlad"
    And I should see "5 pts"

  Scenario: User gets extra points for connection to a user with a bounty
    When "+14155551212" sends SMS "follow phil"
    And "+18085551212" sends SMS "yes"
    And I go to the activity page
    Then I should see "Dan is now a fan of Phil"
    And I should see "12 pts"

  Scenario: User gets points for connecting just once
    When "+14155551212" sends SMS "follow vlad"
    And "+16175551212" sends SMS "yes"
    When "+14155551212" sends SMS "unfollow vlad"
    When "+14155551212" sends SMS "follow vlad"
    And "+16175551212" sends SMS "yes"
    And I go to the activity page
    Then I should see "5 pts" just once

  Scenario: User gets message for connecting to a user with a bounty when demo has bounty
    When "+14155551212" sends SMS "follow phil"
    And "+18085551212" sends SMS "yes"
    And DJ cranks 10 times
    Then "+14155551212" should have received SMS "Phil has approved your request to be a fan. You've collected 5 bonus points for the connection, plus another 7 bonus points."

  Scenario: User gets message for connecting to a user with 0 bounty when demo has bounty
    When "+18085551212" sends SMS "follow dan"
    And "+14155551212" sends SMS "yes"
    And DJ cranks 5 times
    Then "+18085551212" should have received SMS "Dan has approved your request to be a fan. You've collected 5 bonus points for the connection."

  Scenario: User gets message for connecting to a user with bounty when demo has 0 bounty
    When "+13055551212" sends SMS "follow fred"
    And "+12125551212" sends SMS "yes"
    And DJ cranks 10 times
    Then "+13055551212" should have received SMS "Fred has approved your request to be a fan. You've collected 7 bonus points for the connection."

  Scenario: User gets message for connecting to a user with 0 bounty when demo has 0 bounty
    When "+12125551212" sends SMS "follow tom"
    And "+13055551212" sends SMS "yes"
    And DJ cranks 10 times
    Then "+12125551212" should have received SMS "Tom has approved your request to be a fan."

  Scenario: User gets message for connecting to a user with bounty when demo has no bounty
    When "+16505551212" sends SMS "follow bleh"
    And "+14085551212" sends SMS "yes"
    And DJ cranks 10 times
    Then "+16505551212" should have received SMS "Bleh has approved your request to be a fan."

  Scenario: User gets message for connecting to a user with 0 bounty when demo has no bounty
    When "+14085551212" sends SMS "follow feh"
    And "+16505551212" sends SMS "yes"
    And DJ cranks 10 times
    Then "+14085551212" should have received SMS "Feh has approved your request to be a fan."
