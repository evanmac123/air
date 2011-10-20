Feature: User asks about prizes

  Scenario: Demo has prizes
    Given the following demo exists:
      | company name | prize                                    |
      | GenerousCo   | Ninety-nine bottles of beer on the wall. |
    And the following user exists:
      | name | phone number | demo                     |
      | Bob  | +14155551212 | company_name: GenerousCo |
    When "+14155551212" sends SMS "prizes"
    Then "+14155551212" should have received an SMS "Ninety-nine bottles of beer on the wall."

  Scenario: Demo has no prizes
    Given the following user exists:
      | name | phone number |
      | Bob  | +14155551212 |
    When "+14155551212" sends SMS "prizes"
    Then "+14155551212" should have received an SMS "Sorry, no physical prizes this time. This one's just for the joy of the contest."
