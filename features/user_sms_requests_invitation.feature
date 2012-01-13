Feature: User requests an invitation via SMS

  Background:
    Given the following user exists:
      | name  |
      | Pavel |
    And the following self inviting domain exists:
      | domain      |
      | example.com |
  Scenario: Pavel texts us his email address, gets an invitation, and fills it out
    When "+14155551213" sends SMS "email@example.com"
    Then "+14155551213" should have received an SMS "An invitation has been sent to email@example.com."
    And "email@example.com" should receive an email
    When "email@example.com" opens the email
    And they click the first link in the email
    Then I should see "Choose a unique ID"
    And I should see "(415) 555-1213"
    And I should not see "Enter your mobile number"
    And I should not see "We'll send you an SMS with instructions on the next step."
    And I should see "Name"
    And I should see "email@example.com"
