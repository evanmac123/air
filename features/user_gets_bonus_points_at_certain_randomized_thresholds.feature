Feature: User gets bonus points at thresholds with some randomness built in

  Background: 
    Given the following demo exists:
      | company name |
      | FooCo        |
    And the following rules exist:
      | reply   | points | description  | demo                |
      | water   | 1      | drank water  | company_name: FooCo |
      | cheese  | 2      | ate cheese   | company_name: FooCo |
      | kitten  | 3      | ate a kitten | company_name: FooCo |
      | awesome | 13     | was awesome  | company_name: FooCo |
    And the following primary values exist:
      | value       | rule           |
      | drank water | reply: water   |
      | ate cheese  | reply: cheese  |
      | ate kitten  | reply: kitten  |
      | was awesome | reply: awesome |
      | set trap    | reply: trap    |
    And the following bonus thresholds exist:
      | min_points | max_points | award | demo                |
      | 9          | 11         | 3     | company_name: FooCo | 
      | 19         | 22         | 5     | company_name: FooCo |
      | 31         | 38         | 5     | company_name: FooCo |
    And the following users exist:
      | name | phone number | points | demo                |
      | Vlad | +14155551212 | 8      | company_name: FooCo | 
      | Dan  | +16175551212 | 29     | company_name: FooCo |
    And "Vlad" has the password "foo"
    And I sign in via the login page with "Vlad/foo"

  Scenario: User hits max points for a threshold
    When "+14155551212" sends SMS "ate kitten"
    And a decent interval has passed
    And DJ cranks once
    And I go to the activity page
    Then I should see "Vlad 14 points"
    And I should see "Vlad got 3 bonus points for passing a bonus threshold"
    And "+14155551212" should have received an SMS including "You got 3 bonus points for passing a bonus threshold!"

  Scenario: User gets in between min and max points for a threshold and the RNG favors them
    Given the RNG is predisposed to hand out bonus points
    When "+14155551212" sends SMS "ate cheese"
    And a decent interval has passed
    And DJ cranks once
    And I go to the activity page
    Then I should see "Vlad 13 points"
    And I should see "Vlad got 3 bonus points for passing a bonus threshold"
    And "+14155551212" should have received an SMS including "You got 3 bonus points for passing a bonus threshold!"

  Scenario: User gets in between min and max points for a threshold but the RNG favors them not
    Given the RNG is not predisposed to hand out bonus points
    When "+14155551212" sends SMS "ate cheese"
    And a decent interval has passed
    And DJ cranks once
    And I go to the activity page
    Then I should see "Vlad 10 points"
    And I should not see "bonus points for passing a bonus threshold"
    And "+14155551212" should not have received an SMS including "bonus points"

  Scenario: User passes one threshold and hits within another, when the RNG favors them
    Given the RNG is predisposed to hand out bonus points
    When "+14155551212" sends SMS "was awesome"
    And I go to the activity page
    And a decent interval has passed
    And DJ cranks 10 times
    Then I should see "Vlad 29 points"
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
    Then I should see "Vlad 24 points"
    And I should see "Vlad got 3 bonus points for passing a bonus threshold"
    And I should not see "5 bonus points"
    And "+14155551212" should have received an SMS including "You got 3 bonus points for passing a bonus threshold!"
    And "+14155551212" should not have received an SMS including "5 bonus points"

  Scenario: User only gets points once per threshold
    Given the RNG is predisposed to hand out bonus points
    When "+16175551212" sends SMS "ate cheese"
    And I go to the activity page
    Then I should see "Dan 36 points"
    And I should see "Dan got 5 bonus points for passing a bonus threshold"
