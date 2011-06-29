Feature: User levels up

  Background:
    Given the following demo exists:
      | company name |
      | FooCo        |
    And the following users exist:
      | name | phone number | points | demo                |
      | Vlad | +14155551212 | 7      | company_name: FooCo |
    And the following rules exist:
      | reply  | points | demo                |
      | blah   | 1      | company_name: FooCo |
      | good   | 3      | company_name: FooCo |
      | better | 4      | company_name: FooCo |
      | best   | 14     | company_name: FooCo |
    And the following primary values exist:
      | value      | rule          |  
      | did blah   | reply: blah   |
      | did good   | reply: good   |
      | did better | reply: better |
      | did best   | reply: best   |
    And the following levels exist:
      | name           | threshold | demo                |
      | level 1 (N00b) | 10        | company_name: FooCo |
      | level 2 (Pawn) | 21        | company_name: FooCo |
    And "Vlad" has password "foo"
    And I sign in via the login page with "Vlad/foo"

  Scenario: User levels when hitting point threshold
    When "+14155551212" sends SMS "did good"
    And DJ cranks once
    And I go to the activity page
    Then I should see "Level: level 1 (N00b)"
    And "+14155551212" should have received an SMS "You've reached level 1 (N00b)!"

  Scenario: User levels multiply when passing multiple point thresholds
    When "+14155551212" sends SMS "did best"
    And DJ cranks 10 times
    And I go to the activity page
    Then I should see "Level: level 1 (N00b)"
    Then I should see "Level: level 2 (Pawn)"
    And "+14155551212" should have received an SMS "You've reached level 2 (Pawn)!"

  Scenario: User levels when passing point threshold
    When "+14155551212" sends SMS "did better"
    And DJ cranks once
    And I go to the activity page
    Then I should see "Level: level 1 (N00b)"
    And "+14155551212" should have received an SMS "You've reached level 1 (N00b)!"

  Scenario: User doesn't level when not passing point threshold
    When "+14155551212" sends SMS "did blah"
    And DJ cranks 10 times
    And I go to the activity page
    Then I should not see "level 1 (N00b)"
    And "+14155551212" should not have received an SMS including "level 1 (N00b)"
