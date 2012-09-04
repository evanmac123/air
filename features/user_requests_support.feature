Feature: User requests tech support
  Background:
    Given the following demo exists:
      | name         | phone number |
      | PEBCAK       | +14158675309 |
    And the following users exist:
      | phone number | name | email          | demo                 |
      | +14155551212 | Joe  | joe@pebcak.com | name: PEBCAK |
      | +14155551213 | Bob  | bob@pebcak.com | name: PEBCAK |
    And "+14155551212" sends SMS "hi" to "+14158675309"
    And "+14155551212" sends SMS "hello" to "+14158675309"
    And "+14155551212" sends SMS "what's up" to "+14158675309"
    And "+14155551213" sends SMS "herp" to "+14158675309"
    And "+14155551213" sends SMS "derp" to "+14158675309"
    And "+14155551213" sends SMS "ferp" to "+14158675309"
    And "+14155551212" sends SMS "support" to "+14158675309"
    And "+14155551213" sends SMS "support" to "+14158675309"

  Scenario: User gets response about when they can expect help
    Then "+14155551212" should have received SMS "Got it. We'll have someone email you shortly. Tech support is open 9 AM to 6 PM ET. If it's outside those hours, we'll follow-up first thing when we open."  
    And "+14155551213" should have received SMS "Got it. We'll have someone email you shortly. Tech support is open 9 AM to 6 PM ET. If it's outside those hours, we'll follow-up first thing when we open."  

  Scenario: Admin gets emailed support request
    When DJ cranks 2 times
    
    Then support should have received a support email about "Joe/PEBCAK/joe@pebcak.com/+14155551212" with recent acts "what's up/hello/hi"
    And support should have received a support email about "Bob/PEBCAK/bob@pebcak.com/+14155551213" with recent acts "ferp/derp/herp"

  Scenario: Demo has custom support reply
    Given the following demo exists:
      | name | phone number | custom support reply |
      | derp | +19099999999 | On it, chief.        |
    And the following user exists:
      | phone number | demo       |
      | +18088888888 | name: derp |
    When "+18088888888" sends SMS "support" to "+19099999999"
    Then "+18088888888" should have received SMS "On it, chief."
