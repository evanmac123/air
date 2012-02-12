Feature: User gets bonus points at thresholds with some randomness built in

  Background: 
    Given the following demo exists:
      | name  |
      | FooCo |
    And the following rules exist:
      | reply   | points | description  | demo        |
      | water   | 1      | drank water  | name: FooCo |
      | cheese  | 2      | ate cheese   | name: FooCo |
      | kitten  | 3      | ate a kitten | name: FooCo |
      | awesome | 13     | was awesome  | name: FooCo |
    And the following primary values exist:
      | value       | rule           |
      | drank water | reply: water   |
      | ate cheese  | reply: cheese  |
      | ate kitten  | reply: kitten  |
      | was awesome | reply: awesome |
      | set trap    | reply: trap    |
    And the following bonus thresholds exist:
      | min_points | max_points | award | demo                |
      | 9          | 11         | 3     | name: FooCo | 
      | 19         | 22         | 5     | name: FooCo |
      | 31         | 38         | 5     | name: FooCo |
    And the following claimed users exist:
      | name | email            | phone number | points | privacy level | demo        |
      | Vlad | vlad@example.com | +14155551212 | 8      | everybody     | name: FooCo | 
      | Dan  | dan@example.com  | +16175551212 | 29     | everybody     | name: FooCo |
    And "Vlad" has the password "foobar"
    And I sign in via the login page with "Vlad/foobar"

  Scenario: User hits max points for a threshold
    When "+14155551212" sends SMS "ate kitten"
    And a decent interval has passed
    Given a clear email queue
    And DJ cranks 10 times
    And I go to the activity page
    # Then I should see "Vlad 14 pts"
    And I should see "Vlad got 3 bonus points for passing a bonus threshold"
    And "+14155551212" should have received an SMS including "You got 3 bonus points for passing a bonus threshold!"

  Scenario: User finishing a threshold via SMS gets side message via SMS
    When "+14155551212" sends SMS "ate kitten"
    And a decent interval has passed
    Given a clear email queue
    And DJ cranks 10 times
    Then "+14155551212" should have received an SMS including "passing a bonus threshold"
    But "vlad@example.com" should receive no email

  Scenario: User finishing a threshold via email gets side message via email
    When "vlad@example.com" sends email with subject "ate kitten" and body "ate kitten"
    And a decent interval has passed
    And DJ cranks 10 times
    Then "vlad@example.com" should receive an email with "passing a bonus threshold" in the email body
    But "+14155551212" should not have received any SMSes

  Scenario: User finishing a threshold via web sees completion message in the flash
    When I sign in via the login page with "Vlad/foobar"
    And I enter the act code "ate kitten"
    And a decent interval has passed
    Given a clear email queue
    And DJ cranks 10 times
    Then "+14155551212" should not have received any SMSes
    And "vlad@hengage.com" should receive no email
    But I should see "passing a bonus threshold"

  Scenario: User gets in between min and max points for a threshold and the RNG favors them
    Given the RNG is predisposed to hand out bonus points
    When "+14155551212" sends SMS "ate cheese"
    And a decent interval has passed
    And DJ cranks 10 times
    And I go to the activity page
    # Then I should see "Vlad 13 pts"
    And I should see "Vlad got 3 bonus points for passing a bonus threshold"
    And "+14155551212" should have received an SMS including "You got 3 bonus points for passing a bonus threshold!"

  Scenario: User gets in between min and max points for a threshold but the RNG favors them not
    Given the RNG is not predisposed to hand out bonus points
    When "+14155551212" sends SMS "ate cheese"
    And a decent interval has passed
    And DJ cranks once
    And I go to the activity page
    # Then I should see "Vlad 10 pts"
    And I should not see "bonus points for passing a bonus threshold"
    And "+14155551212" should not have received an SMS including "bonus points"

  Scenario: User passes one threshold and hits within another, when the RNG favors them
    Given the RNG is predisposed to hand out bonus points
    When "+14155551212" sends SMS "was awesome"
    And I go to the activity page
    And a decent interval has passed
    And DJ cranks 10 times
    # Then I should see "Vlad 29 pts"
    And I should see "Vlad got 3 bonus points for passing a bonus threshold"
    And I should see "Vlad got 5 bonus points for passing a bonus threshold"
    And "+14155551212" should have received an SMS including "You got 3 bonus points for passing a bonus threshold!"
    And "+14155551212" should have received an SMS including "You got 5 bonus points for passing a bonus threshold!"

  Scenario: User passes one threshold and hits within another, but the RNG frowns upon them
    Given the RNG is not predisposed to hand out bonus points
    When "+14155551212" sends SMS "was awesome"
    And a decent interval has passed
    And DJ cranks 10 times
    And I go to the activity page
    # Then I should see "Vlad 24 pts"
    And I should see "Vlad got 3 bonus points for passing a bonus threshold"
    And I should not see "5 bonus points"
    And "+14155551212" should have received an SMS including "You got 3 bonus points for passing a bonus threshold!"
    And "+14155551212" should not have received an SMS including "5 bonus points"

  Scenario: User only gets points once per threshold
    Given the RNG is predisposed to hand out bonus points
    When "+16175551212" sends SMS "ate cheese"
    And I go to the activity page
    # Then I should see "Dan 36 pts"
    And I should see "Dan got 5 bonus points for passing a bonus threshold"
