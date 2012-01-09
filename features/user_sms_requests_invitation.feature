Feature: User requests an invitation via SMS

  Background:
    Given the following user exists:
      | name  |
      | Pavel |
    And the following self inviting domain exists:
      | domain      |
      | example.com |
  Scenario:
    When "+14155551212" sends SMS "email@example.com"
    Then "+14155551212" should have received an SMS "An invitation has been sent to email@example.com."
    And "email@example.com" should have received an invitation
