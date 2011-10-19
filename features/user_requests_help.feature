Feature: User requests help

  Background:
    Given the following demo exists:
      | company name |
      | PEBCAK       |
    And the following users exist:
      | phone number | name | email          | demo                 |
      | +14155551212 | Joe  | joe@pebcak.com | company_name: PEBCAK |
      | +14155551213 | Bob  | bob@pebcak.com | company_name: PEBCAK |
    And "+14155551212" sends SMS "hi"
    And "+14155551212" sends SMS "hello"
    And "+14155551212" sends SMS "what's up"
    And "+14155551213" sends SMS "herp"
    And "+14155551213" sends SMS "derp"
    And "+14155551213" sends SMS "ferp"

  Scenario: During business hours
    Given time is frozen at "2011-08-01 09:00:00 -0400"
    And "+14155551212" sends SMS "help"
    And time is frozen at "2011-08-01 20:59:59 -0400"
    And "+14155551213" sends SMS "help"
    Then "+14155551212" should have received SMS "Got it. We'll have someone get back to your shortly. Tech support is open 9 AM to 9 PM ET. If it's outside those hours, we'll follow-up first thing tomorrow."
    And "+14155551213" should have received SMS "Got it. We'll have someone get back to your shortly. Tech support is open 9 AM to 9 PM ET. If it's outside those hours, we'll follow-up first thing tomorrow."

  Scenario: After business hours
    Given time is frozen at "2011-08-01 08:59:59 -0400"
    And "+14155551212" sends SMS "help"
    And time is frozen at "2011-08-01 21:00:00 -0400"
    And "+14155551213" sends SMS "help"
    Then "+14155551212" should have received SMS "Got it. We'll have someone get back to your shortly. Tech support is open 9 AM to 9 PM ET. If it's outside those hours, we'll follow-up first thing tomorrow."
    And "+14155551213" should have received SMS "Got it. We'll have someone get back to your shortly. Tech support is open 9 AM to 9 PM ET. If it's outside those hours, we'll follow-up first thing tomorrow."

  Scenario: Admin gets emailed support request
    When "+14155551212" sends SMS "help"
    And "+14155551213" sends SMS "help"
    And DJ cranks 2 times
    Then support should have received a support email about "Joe/PEBCAK/joe@pebcak.com/+14155551212" with recent acts "what's up/hello/hi"
    And support should have received a support email about "Bob/PEBCAK/bob@pebcak.com/+14155551213" with recent acts "ferp/derp/herp"
