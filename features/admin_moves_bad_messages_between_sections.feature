Feature: Admin can move bad messages between sections

  Scenario: Admin moves bad messages around between sections
    Given the following new bad messages exist:
      | phone number | body             | received at          |
      | +14155551212 | I bear watching. | 2011-01-01 15:00 UTC |
      | +14155551213 | I don't matter.  | 2011-01-02 15:01 UTC |
    And the following watchlisted bad message exists:
      | phone number | body             | received at          |
      | +14155551214 | I'm done.        | 2011-01-03 15:02 UTC |
    And the following bad message exists:
      | phone_number | body             | received at          |
      | +14155551215 | I matter again.  | 2011-01-04 15:03 UTC |
    When I sign in as an admin via the login page
    And I go to the bad message log page
    And I reply to the message "I bear watching."
    And I dismiss the message "I don't matter."
    And I dismiss the message "I'm done."
    And I reply to the message "I matter again."
    Then I should be on the bad message log page
    And I should not see any new bad messages
    And I should see the following watchlisted bad SMS messages:
      | phone_number | message_body     | received_at          |
      | +14155551212 | I bear watching. | 2011-01-01 15:00 UTC |
      | +14155551215 | I matter again.  | 2011-01-04 15:03 UTC |
    And I should see the following messages in the all-message section:
      | phone_number | message_body     | received_at          |
      | +14155551212 | I bear watching. | 2011-01-01 15:00 UTC |
      | +14155551213 | I don't matter.  | 2011-01-02 15:01 UTC |
      | +14155551214 | I'm done.        | 2011-01-03 15:02 UTC |
      | +14155551215 | I matter again.  | 2011-01-04 15:03 UTC |
