Feature: Full text rule search

  Background:
    Given the following rules exist:
      | value      | suggestible |
      | ate banana | true        |
      | ate kitten | true        |
      | ate poison | false       |
      | worked out | true        |
    And the following user exists:
      | name | phone number |
      | Dan  | +16175551212 |

  Scenario: User almost gets a command right
    When "+16175551212" sends SMS "ate baked alaska"
    Then "+16175551212" should have received an SMS 'I didn't quite get what you meant. Maybe try "ate banana" or "ate kitten"?'

  Scenario: User comes nowhere near a command
    When "+16175551212" sends SMS "fought eighteen bears"
    Then "+16175551212" should have received an SMS "Sorry, I don't understand what that means."
