Feature: Full text rule search

  Background:
    Given the following claimed user exists:
      | name | phone number | demo          |
      | Dan  | +16175551212 | name: FooCorp |
    And "Dan" has the password "foobar"
    And I sign in via the login page with "Dan/foobar"
    And time is frozen at "2010-05-01 17:00:00"

  Scenario: User comes nowhere near a command
    When "+16175551212" sends SMS "fought eighteen bears"
    Then "+16175551212" should have received an SMS "Sorry, I don't understand what "fought eighteen bears" means."
