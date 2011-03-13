Feature: Admin can talk with a user via the bad message log

  As an admin
  I want to be able to offer guidance via SMS about valid commands
  So the paying customers will have warm fuzzies about us instead of getting frustrated

  Background:
    Given the following bad messages exist:
      | phone_number |
      | +14152613077 |
    And time is frozen at "2010-05-01 17:00:00 -0500"
    When I sign in via the login page
    And I go to the bad message log page
    And I follow "Reply"

  Scenario: Admin replies to bad SMS
    When I fill in "Say to user:" with "It looks like you're having trouble."
    And I press "Send"
    Then I should be on the bad message log page
    And "+14152613077" should have received an SMS "It looks like you're having trouble."
    And I should see "Message sent to +14152613077"
    And I should see "Replied to by you, May 01, 2010 at 06:00 PM Eastern"

  Scenario: Admin sees who else replied to bad message
    Given the following bad message reply exists:
      | sender           | created_at                  |
      | name: Jimmy Jojo | "2009-04-12 12:00:00 -0500" |
    When I go to the bad message log page
    And I dump the page
    Then I should see "Replied to by Jimmy Jojo, April 12, 2009 at 01:00 PM Eastern"

  Scenario: Admin tries to send over-length reply
    When I fill in "Say to user:" with "This is sure a long reply. I guess I let my enthusiasm for excellent customer service get away from me. Hail Satan. Is this over 160 characters yet? No, not quite. Now it is."
    And I press "Send"
    Then I should be on the bad message log page
    And I should see "Couldn't send message: Body is too long (maximum is 160 characters)"
    And I should not see "Replied to by you, May 01, 2010 at 06:00 PM Eastern"

  Scenario: Admin sees conversations as threads
    Given time is unfrozen
    And the following bad messages with replies exist:
      | phone_number | body                                       | reply                             |
      | +14152613077 | help                                       | It looks like you asked for help. |
      | +14152613077 | No kidding, Clippy.                        | Are you writing a letter?         |
      | +14152613077 | No, I wanna play an SMS-based health game. | Oh. Please hold.                  |
    When I go to the bad message log page
    Then I should see a thread:
      | Oh. Please hold.                           |
      | No, I wanna play an SMS-based health game. | 
      | Are you writing a letter?                  |
      | No kidding, Clippy.                        | 
      | It looks like you asked for help.          |
      | help                                       | 
