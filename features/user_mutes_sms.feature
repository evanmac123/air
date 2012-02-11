Feature: User mutes SMS

  Background:
    Given the following claimed users exist:
      | name     | phone number | email               |
      | Joe Bob  | +14155551212 | joebob@example.com  |
      | Bob Fred | +16175551212 | bobfred@example.com |
      | Fred Joe | +18085551212 | fredjoe@example.com |

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

  Scenario: User gets mute reminder after 10 texts
    When the system sends "Text 1" to user "Joe Bob"
    When the system sends "Text 2" to user "Joe Bob"
    When the system sends "Text 3" to user "Joe Bob"
    When the system sends "Text 4" to user "Joe Bob"
    When the system sends "Text 5" to user "Joe Bob"
    When the system sends "Text 6" to user "Joe Bob"
    When the system sends "Text 7" to user "Joe Bob"
    When the system sends "Text 8" to user "Joe Bob"
    When the system sends "Text 9" to user "Joe Bob"
    And DJ cranks 20 times
    Then "+14155551212" should not have received SMS "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours."
    And "joebob@example.com" should receive no emails

    When the system sends "Text 10" to user "Joe Bob"
    And DJ cranks 10 times
    Then "+14155551212" should have received SMS "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text GOT IT."
    When "joebob@example.com" opens the email
    Then I should see "To stop getting this reminder, text GOT IT" in the email body

    When I clear all sent texts
    Given a clear email queue 
    And the system sends "Text 11" to user "Joe Bob"
    And DJ cranks 10 times
    Then "+14155551212" should not have received SMS "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text GOT IT."
    And "joebob@example.com" should receive no email

  Scenario: Mute reminder threshold can be set on a custom basis
    Given the following demo exists:
      | name     | mute notice threshold |
      | CustomCo | 7                     |
    And the following user exists:
      | name            | phone number | demo           |
      | Frank Dillinger | +13055551212 | name: CustomCo |
    When the system sends "Text 1" to user "Frank Dillinger"
    When the system sends "Text 2" to user "Frank Dillinger"
    When the system sends "Text 3" to user "Frank Dillinger"
    When the system sends "Text 4" to user "Frank Dillinger"
    When the system sends "Text 5" to user "Frank Dillinger"
    When the system sends "Text 6" to user "Frank Dillinger"
    And DJ cranks 10 times
    Then "+13055551212" should not have received SMS "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text GOT IT."
    When the system sends "Text 7" to user "Frank Dillinger"
    And DJ cranks 5 times
    Then "+13055551212" should have received SMS "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text GOT IT."
    When I clear all sent texts
    And the system sends "Text 8" to user "Frank Dillinger"
    And DJ cranks 10 times
    Then "+13055551212" should not have received SMS "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text GOT IT."



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
