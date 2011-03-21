Feature: Bad message log

  Scenario: New unparseable message gets logged
    Given the following user exists:
      | name | phone_number |
      | Bob  | +14155551212 |
    And time is frozen at "2010-05-01 17:00:00"
    And "+14155551212" sends SMS "FOO BAR I SAY"
    And time is frozen at "2010-05-01 17:05:00"
    And "+16178675309" sends SMS "a/s/l?"
    When I sign in via the login page
    And I go to the bad message log page
    Then I should see the following new bad SMS messages:
      | name | phone_number | message_body  | received_at         |
      | Bob  | +14155551212 | FOO BAR I SAY | 2010-05-01 17:00:00 |
      |      | +16178675309 | a/s/l?        | 2010-05-01 17:05:00 |
    And I should see "2 new bad messages"

  Scenario: New unparseable message from a number on the watch list gets logged
    Given the following watchlisted bad message exists:
      | phone_number | body   | received_at          |
      | +14155551212 | First! | 2010-05-01 17:00 UTC |
    And time is frozen at "2010-05-01 18:00 UTC"
    And "+14155551212" sends SMS "FOO BAR"
    When I sign in via the login page
    And I go to the bad message log page
    Then I should see the following watchlisted bad SMS messages:
      | phone_number | message_body | received_at          |
      | +14155551212 | First!       | 2010-05-01 17:00 UTC |
      | +14155551212 | FOO BAR      | 2010-05-01 18:00 UTC |
    And I should see "2 new messages to reply to"
    And I should not see any new bad messages

  Scenario: All bad messages appear in the appropriate section
    Given the following new bad message exists:
      | phone_number | body      | received_at          |
      | +14155551212 | I am new. | 2011-01-02 13:00 UTC |
    And the following watchlisted bad message exists:
      | phone number | body      | received_at          |
      | +16175551212 | Watch me! | 2010-06-06 18:00 UTC |
    And the following bad message reply exists:
      | bad_message     | body                   |
      | body: Watch me! | Why, do you do tricks? |
    And the following bad message exists:
      | phone number | body             | received_at          |
      | +18085551212 | Nothing special. | 2009-05-04 12:00 UTC |
    And the following bad message reply exists:
      | bad message            | body    |
      | body: Nothing special. | Agreed. |
    When I sign in via the login page
    And I go to the bad message log page
    Then I should see the following messages in the all-message section:
      | phone_number | message_body     | received_at          |
      | +14155551212 | I am new.        | 2011-01-02 13:00 UTC |
      | +16175551212 | Watch me!        | 2010-06-06 18:00 UTC |
      | +18085551212 | Nothing special. | 2009-05-04 12:00 UTC |
    And I should see "Why, do you do tricks?" in the all-message section
    And I should see "Agreed." in the all-message section
    And I should see "3 messages total" in the all-message section
