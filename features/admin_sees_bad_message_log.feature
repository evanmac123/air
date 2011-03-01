Feature: Bad message log

  Scenario: Unparseable message gets logged where the admin can see it
    Given the following user exists:
      | name | phone_number |
      | Bob  | +14155551212 |
    And the following rule exists:
      | key       | value  |
      | name: ate | banana |
    And time is frozen at "2010-05-01 17:00:00"
    And "+14155551212" sends SMS "FOO BAR I SAY"
    And time is frozen at "2010-05-01 17:05:00"
    And "+16178675309" sends SMS "a/s/l?"
    When I sign in via the login page
    And I go to the bad message log page
    Then I should see the following bad SMS messages:
      | name | phone_number | message_body  | received_at         |
      | Bob  | +14155551212 | FOO BAR I SAY | 2010-05-01 17:00:00 |
      |      | +16178675309 | a/s/l?        | 2010-05-01 17:05:00 |
    And I should not see "ate banana"
