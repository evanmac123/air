Feature: User mutes SMS

  Scenario: User mutes SMS
    Given the following claimed user exists:
      | name    | phone number |
      | Joe Bob | +14155551212 |
    And time is frozen at "2010-01-01 00:00:00 +0000"
    And I clear all sent texts

    When the system sends "Text 1" to user "Joe Bob"
    And the system sends "Text 2" to user "Joe Bob"
    And DJ cranks 5 times
    And "+14155551212" sends SMS "mute"

    And the system sends "Text 3" to user "Joe Bob"
    And DJ cranks 5 times
    And 12 hours pass
    And the system sends "Text 4" to user "Joe Bob"
    And DJ cranks 5 times
    And 12 hours pass
    And the system sends "Text 5" to user "Joe Bob"
    And DJ cranks 5 times
    And 12 hours pass
    And the system sends "Text 6" to user "Joe Bob"
    And DJ cranks 5 times

    Then "+14155551212" should have received SMS "Text 1"
    And "+14155551212" should have received SMS "Text 2"
    And "+14155551212" should have received SMS "Text 5"
    And "+14155551212" should have received SMS "Text 6"
    And "+14155551212" should have received SMS "OK, you won't get any more texts from us for at least 24 hours."

    But "+14155551212" should not have received SMS "Text 3"
    And "+14155551212" should not have received SMS "Text 4"
