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
    And I sign in via the login page
    And time is frozen at "2010-05-01 17:00:00"

  Scenario: User almost gets a command right
    When "+16175551212" sends SMS "ate baked alaska"
    And I go to the bad message log page
    Then "+16175551212" should have received an SMS 'I didn't quite get what you meant. Maybe try "ate banana" or "ate kitten"?'
    And I should see the following new bad SMS messages:
      | name | phone_number | message_body     | received_at         |
      | Dan  | +16175551212 | ate baked alaska | 2010-05-01 17:00:00 |
    And I should see "(has automated suggestion)"
    And I should see `System automatically replied: I didn't quite get what you meant. Maybe try "ate banana" or "ate kitten"?`

  Scenario: User comes nowhere near a command
    When "+16175551212" sends SMS "fought eighteen bears"
    And I go to the bad message log page
    Then "+16175551212" should have received an SMS "Sorry, I don't understand what that means."    
    And I should see the following new bad SMS messages:
      | name | phone_number | message_body          | received_at         |
      | Dan  | +16175551212 | fought eighteen bears | 2010-05-01 17:00:00 |
    And I should not see "(has automated suggestion)"
    And I should not see "Sorry, I don't understand what that means."
