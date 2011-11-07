Feature: User gets timed bonus

  Background:
    Given the following demo exists:
      | company name |
      | FooCo        |
    And the following users exist:
      | name | phone number | demo                |
      | Phil | +14155551212 | company_name: FooCo |
      | Vlad | +16175551212 | company_name: FooCo |
    And the following rules exist:
      | reply       | points |
      | did a thing | 5      |
    And the following rule values exist:
      | value     | rule               |
      | did thing | reply: did a thing |
    And I need to implement timed bonuses

  Scenario: User gets bonus for acting in the proper time
    Given I need to write this
