Feature: User mutes SMS

  Background:
    Given the following claimed users exist:
      | name     | phone number |
      | Joe Bob  | +14155551212 |
      | Bob Fred | +16175551212 |
      | Fred Joe | +18085551212 |

  Scenario: User mutes SMS
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

  Scenario: User gets mute reminder after 5 texts
    When the system sends "Text 1" to user "Joe Bob"
    When the system sends "Text 2" to user "Joe Bob"
    When the system sends "Text 3" to user "Joe Bob"
    When the system sends "Text 4" to user "Joe Bob"
    And DJ cranks 10 times
    Then "+14155551212" should not have received SMS "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours."

    When the system sends "Text 5" to user "Joe Bob"
    And DJ cranks 10 times
    Then "+14155551212" should have received SMS "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text GOT IT."

    When I clear all sent texts
    And the system sends "Text 6" to user "Joe Bob"
    And DJ cranks 10 times
    Then "+14155551212" should not have received SMS "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text GOT IT."

  Scenario: User texts GOT IT or similar to stop getting mute reminder
    When the system sends "Text 1" to user "Joe Bob"
    When the system sends "Text 2" to user "Joe Bob"
    When the system sends "Text 3" to user "Joe Bob"
    When the system sends "Text 4" to user "Joe Bob"
    When the system sends "Text 1" to user "Bob Fred"
    When the system sends "Text 2" to user "Bob Fred"
    When the system sends "Text 3" to user "Bob Fred"
    When the system sends "Text 4" to user "Bob Fred"
    When the system sends "Text 1" to user "Fred Joe"
    When the system sends "Text 2" to user "Fred Joe"
    When the system sends "Text 3" to user "Fred Joe"
    When the system sends "Text 4" to user "Fred Joe"
    And DJ cranks 15 times

    And "+14155551212" sends SMS "gotit"
    And "+16175551212" sends SMS "got it"
    And "+18085551212" sends SMS "got a lot of cheese whiz"

    And the system sends "Text 5" to user "Joe Bob"
    And the system sends "Text 5" to user "Bob Fred"
    And the system sends "Text 5" to user "Fred Joe"
    And DJ cranks 10 times

    Then "+14155551212" should not have received SMS "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text GOT IT."
    Then "+16175551212" should not have received SMS "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text GOT IT."
    Then "+18085551212" should not have received SMS "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text GOT IT."

    But "+14155551212" should have received SMS "OK, we won't remind you about the MUTE command henceforth."
    And "+16175551212" should have received SMS "OK, we won't remind you about the MUTE command henceforth."
    And "+18085551212" should have received SMS "OK, we won't remind you about the MUTE command henceforth."
