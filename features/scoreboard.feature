Feature: Scoreboard

  Background:
    Given the following users exist:
      | name | points | demo                | phone_number  |
      | Lazy | 0      | company_name: Alpha | +14155551212  |
      | Tony | 24     | company_name: Alpha | +16179329523  |
      | Bleh | 2      | company_name: Alpha | +19082384923  |
      | Phil | 634923 | company_name: Alpha | +18953409234  |
      | Vlad | 17     | company_name: Alpha | +12039095234  |
      | Dan  | 10     | company_name: Alpha | +12093492304  |
      | Who  | 44     | company_name: Enron | +18939849382  |
      | Sven | 24     | company_name: Alpha | +18592834234  |
      | Lou  | 0      | company_name: Alpha |               |
    And "Lazy" has the password "foobar"
    And I sign in via the login page as "Lazy/foobar"

  Scenario: Scoreboard on acts page
    When I go to the acts page
    Then I should see a scoreboard for demo "Alpha"
    And I should see "Tony" with ranking "2"
    And I should see "Sven" with ranking "2"
    And I should see "Vlad" with ranking "4"
    And I should not see "Lou"

  Scenario: Scoreboard on home page
    When I go to the home page
    Then I should see a scoreboard for demo "Alpha"
    And I should see "Tony" with ranking "2"
    And I should see "Sven" with ranking "2"
    And I should see "Vlad" with ranking "4"
    And I should not see "Lou"
