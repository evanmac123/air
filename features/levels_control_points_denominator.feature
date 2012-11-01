Feature: Levels control points denominator

  Background:
    Given the following demo exists:
      | name  |
      | FooCo |
    And the following claimed users exist:
      | name | phone number | points | demo        |
      | Vlad | +14155551212 | 7      | name: FooCo |
    And the following rules exist:
      | reply   | points | demo        |
      | blah.   | 1      | name: FooCo |
      | good.   | 3      | name: FooCo |
      | better. | 4      | name: FooCo |
      | best.   | 14     | name: FooCo |
    And the following primary values exist:
      | value      | rule           |  
      | did blah   | reply: blah.   |
      | did good   | reply: good.   |
      | did better | reply: better. |
      | did best   | reply: best.   |
    And the following levels exist:
      | name           | threshold | demo        |
      | level 1 (N00b) | 10        | name: FooCo |
      | level 2 (Pawn) | 21        | name: FooCo |

  Scenario: User acts and sees point threshold of next or highest level as denominator
    When "+14155551212" sends SMS "did blah"
    Then "+14155551212" should have received an SMS including "blah. Points 8/10, level 1"

    When "+14155551212" sends SMS "did blah"
    Then "+14155551212" should have received an SMS including "blah. Points 9/10, level 1"

    When "+14155551212" sends SMS "did blah"
    Then "+14155551212" should have received an SMS including "blah. Points 0/11, level 2"

    When "+14155551212" sends SMS "did better"
    Then "+14155551212" should have received an SMS including "better. Points 4/11, level 2"

  Scenario: If game has a victory threshold, that gets considered too
    Given "FooCo" has victory threshold 15

    When "+14155551212" sends SMS "did blah"
    Then "+14155551212" should have received an SMS including "blah. Points 8/10, level 1"

    When "+14155551212" sends SMS "did blah"
    Then "+14155551212" should have received an SMS including "blah. Points 9/10, level 1"

    When "+14155551212" sends SMS "did blah"
    Then "+14155551212" should have received an SMS including "blah. Points 0/5, level 2"

    When "+14155551212" sends SMS "did better"
    Then "+14155551212" should have received an SMS including "better. Points 4/5, level 2"

  Scenario: Game's victory threshold also considered if it's greater than any level's and less than the user's score
    Given "FooCo" has victory threshold 40

    When "+14155551212" sends SMS "did best"
    Then "+14155551212" should have received an SMS including "best. Points 0/19, level 3"

    When "+14155551212" sends SMS "did best"
    Then "+14155551212" should have received an SMS including "best. Points 14/19, level 3"
