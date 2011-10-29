Feature: Levels control points denominator

  Background:
    Given the following demo exists:
      | company name |
      | FooCo        |
    And the following users exist:
      | name | phone number | points | demo                |
      | Vlad | +14155551212 | 7      | company_name: FooCo |
    And the following rules exist:
      | reply   | points | demo                |
      | blah.   | 1      | company_name: FooCo |
      | good.   | 3      | company_name: FooCo |
      | better. | 4      | company_name: FooCo |
      | best.   | 14     | company_name: FooCo |
    And the following primary values exist:
      | value      | rule           |  
      | did blah   | reply: blah.   |
      | did good   | reply: good.   |
      | did better | reply: better. |
      | did best   | reply: best.   |
    And the following levels exist:
      | name           | threshold | demo                |
      | level 1 (N00b) | 10        | company_name: FooCo |
      | level 2 (Pawn) | 21        | company_name: FooCo |

  Scenario: User acts and sees point threshold of next or highest level as denominator
    When "+14155551212" sends SMS "did blah"
    Then "+14155551212" should have received an SMS including "blah. Points 8/10"

    When "+14155551212" sends SMS "did blah"
    Then "+14155551212" should have received an SMS including "blah. Points 9/10"

    When "+14155551212" sends SMS "did blah"
    Then "+14155551212" should have received an SMS including "blah. Points 10/21"

    When "+14155551212" sends SMS "did better"
    Then "+14155551212" should have received an SMS including "better. Points 14/21"

    When "+14155551212" sends SMS "did best"
    And I dump all sent texts
    Then "+14155551212" should have received an SMS including "best. Points 28/21"

    When "+14155551212" sends SMS "did best"
    Then "+14155551212" should have received an SMS including "best. Points 42/21"

  Scenario: If game has a victory threshold, that gets considered too
    Given "FooCo" has victory threshold 15

    When "+14155551212" sends SMS "did blah"
    Then "+14155551212" should have received an SMS including "blah. Points 8/10"

    When "+14155551212" sends SMS "did blah"
    Then "+14155551212" should have received an SMS including "blah. Points 9/10"

    When "+14155551212" sends SMS "did blah"
    Then "+14155551212" should have received an SMS including "blah. Points 10/15"

    When "+14155551212" sends SMS "did better"
    Then "+14155551212" should have received an SMS including "better. Points 14/15"

    When "+14155551212" sends SMS "did better"
    And I dump all sent texts
    Then "+14155551212" should have received an SMS including "better. Points 18/21"

    When "+14155551212" sends SMS "did best"
    Then "+14155551212" should have received an SMS including "best. Points 32/21"

  Scenario: Game's victory threshold also considered if it's greater than any level's and less than the user's score
    Given "FooCo" has victory threshold 40

    When "+14155551212" sends SMS "did best"
    And I dump all sent texts
    Then "+14155551212" should have received an SMS including "best. Points 21/40"

    When "+14155551212" sends SMS "did best"
    Then "+14155551212" should have received an SMS including "best. Points 35/40"

    When "+14155551212" sends SMS "did best"
    Then "+14155551212" should have received an SMS including "best. Points 49/40"
