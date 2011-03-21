Feature: Admin can talk with a user via the bad message log

  As an admin
  I want to be able to offer guidance via SMS about valid commands
  So the paying customers will have warm fuzzies about us instead of getting frustrated

  Background:
    Given the following user exists:
      | name | phone_number |
      | Bob  | +14152613077 |
    And the following bad messages exist:
      | phone_number | body        | received_at         |
      | +14152613077 | I need help | 2010-05-01 17:00:00 |
    And time is frozen at "2010-05-01 17:00:00 -0500"
    When I sign in via the login page
    And I go to the bad message log page
    And I follow "Reply and move to watch list"

  Scenario: Admin replies to bad SMS
    When I fill in "Say to user:" with "It looks like you're having trouble."
    And I press "Send"
    Then I should be on the bad message log page
    And "+14152613077" should have received an SMS "It looks like you're having trouble."
    And I should see "Message sent to +14152613077"
    And I should see "It looks like you're having trouble"
    And I should not see any new bad messages
    And I should see the following watchlisted bad SMS messages:
      | name | phone_number | message_body  | received_at             |
      | Bob  | +14152613077 | I need help   | 2010-05-01 17:00:00 UTC |
    And I should see "0 new messages to reply to"

  Scenario: Admin tries to send over-length reply
    When I fill in "Say to user:" with "This is sure a long reply. I guess I let my enthusiasm for excellent customer service get away from me. Hail Satan. Is this over 160 characters yet? No, not quite. Now it is."
    And I press "Send"
    Then I should be on the bad message log page
    And I should see "Couldn't send message: Body is too long (maximum is 160 characters)"
    And I should not see "Message sent to +14152613077"
