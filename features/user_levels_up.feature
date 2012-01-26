Feature: User levels up

  Background:
    Given the following demo exists:
      | name |
      | FooCo        |
    And the following levels exist:
      | name           | threshold | demo                |
      | level 1 (N00b) | 10        | name: FooCo |
      | level 2 (Pawn) | 21        | name: FooCo |
    And the following users exist:
      | name | phone number | points | demo                |
      | Vlad | +14155551212 | 7      | name: FooCo |
      | Joe  | +18085551212 | 6      | name: BarCo |
    And the following rules exist:
      | reply  | points | demo                |
      | blah   | 1      | name: FooCo |
      | good   | 3      | name: FooCo |
      | better | 4      | name: FooCo |
      | best   | 14     | name: FooCo |
    And the following primary values exist:
      | value      | rule          |  
      | did blah   | reply: blah   |
      | did good   | reply: good   |
      | did better | reply: better |
      | did best   | reply: best   |
    And "Vlad" has password "foobar"
    And I sign in via the login page with "Vlad/foobar"

  Scenario: User levels when hitting point threshold
    When "+14155551212" sends SMS "did good"
    And a decent interval has passed
    And DJ cranks 10 times
    And I go to the activity page
    #Then I should see "Level: level 1 (N00b)"
    And "+14155551212" should have received an SMS "You've reached level 1 (N00b)!"

  Scenario: User levels multiply when passing multiple point thresholds
    When "+14155551212" sends SMS "did best"
    And a decent interval has passed
    And DJ cranks 10 times
    And I go to the activity page
    #Then I should see "Level: level 1 (N00b)"
    #Then I should see "Level: level 2 (Pawn)"
    And "+14155551212" should have received an SMS "You've reached level 1 (N00b)!"
    And "+14155551212" should have received an SMS "You've reached level 2 (Pawn)!"

  Scenario: User levels when passing point threshold
    When "+14155551212" sends SMS "did better"
    And a decent interval has passed
    And DJ cranks 10 times
    And I go to the activity page
    # Then I should see "Level: level 1 (N00b)"
    And "+14155551212" should have received an SMS "You've reached level 1 (N00b)!"

  Scenario: User doesn't level when not passing point threshold
    When "+14155551212" sends SMS "did blah"
    And a decent interval has passed
    And DJ cranks 10 times
    And I go to the activity page
    # Then I should not see "level 1 (N00b)"
    And "+14155551212" should not have received an SMS including "level 1 (N00b)"

  Scenario: Levels are awarded retroactively on creation to people in the same demo
    Given the following level exists:
      | name           | threshold | demo                |
      | level 0 (usuk) | 5         | name: FooCo |
    When DJ cranks 5 times
    And a decent interval has passed
    And DJ cranks 5 times
    And I go to the activity page
    # Then I should see "Level: level 0 (usuk)"
    And "+14155551212" should have received an SMS including "level 0 (usuk)"
    But "+14155551212" should not have received an SMS including "level 1 (N00b)"
    # And I should not see "level 1 (N00b)"
    And "+18085551212" should not have received an SMS including "level 0 (usuk)"
    And "+18085551212" should not have received an SMS including "level 1 (N00b)"

