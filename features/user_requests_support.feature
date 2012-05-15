Feature: User requests tech support
  Background:
    Given the following demo exists:
      | name         |
      | PEBCAK       |
    And the following users exist:
      | phone number | name | email          | demo                 |
      | +14155551212 | Joe  | joe@pebcak.com | name: PEBCAK |
      | +14155551213 | Bob  | bob@pebcak.com | name: PEBCAK |
    And "+14155551212" sends SMS "hi"
    And "+14155551212" sends SMS "hello"
    And "+14155551212" sends SMS "what's up"
    And "+14155551213" sends SMS "herp"
    And "+14155551213" sends SMS "derp"
    And "+14155551213" sends SMS "ferp"
    And "+14155551212" sends SMS "support"
    And "+14155551213" sends SMS "support"

  Scenario: User gets response about when they can expect help
    Then "+14155551212" should have received SMS "Got it. We'll have someone email you shortly. Tech support is open 9 AM to 6 PM ET. If it's outside those hours, we'll follow-up first thing when we open."  
    And "+14155551213" should have received SMS "Got it. We'll have someone email you shortly. Tech support is open 9 AM to 6 PM ET. If it's outside those hours, we'll follow-up first thing when we open."  

  Scenario: Admin gets emailed support request
    When DJ cranks 2 times
    
    Then support should have received a support email about "Joe/PEBCAK/joe@pebcak.com/+14155551212" with recent acts "what's up/hello/hi"
    And support should have received a support email about "Bob/PEBCAK/bob@pebcak.com/+14155551213" with recent acts "ferp/derp/herp"
