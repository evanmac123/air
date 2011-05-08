Feature: Scoreboard

  Background:
    Given the following users exist:
      | name   | points | demo                | phone_number |
      | Lazy   | 1      | company_name: Alpha | +14155551212 |
      | Nogood | 1      | company_name: Alpha | +14058239455 |
      | Tony   | 24     | company_name: Alpha | +16179329523 |
      | Bleh   | 3      | company_name: Alpha | +19082384923 |
      | Phil   | 634923 | company_name: Alpha | +18953409234 |
      | Vlad   | 17     | company_name: Alpha | +12039095234 |
      | Dan    | 10     | company_name: Alpha | +12093492304 |
      | Sven   | 24     | company_name: Alpha | +18592834234 |
      | Loser  | 0      | company_name: Alpha | +18630582345 |
      | Blobby | 3      | company_name: Alpha | +18302959203 |
      | Fatso  | 2      | company_name: Alpha | +19380482942 |
      | Fatty  | 2      | company_name: Alpha | +19380482943 |
      | Lou    | 1      | company_name: Alpha |              |
      | Who    | 44     | company_name: Enron | +18939849382 |
    And "Lazy" has the password "foobar"
    And I sign in via the login page as "Lazy/foobar"

  Scenario: Scoreboard on acts page
    When I go to the acts page
    Then I should see a scoreboard for demo "Alpha"
    And I should see "Phil" with ranking "1"
    And I should see "Tony" with ranking "2"
    And I should see "Sven" with ranking "2"
    And I should see "Vlad" with ranking "4"
    And I should see "Dan" with ranking "5"
    And I should see "Bleh" with ranking "6"
    And I should see "Blobby" with ranking "6"
    And I should see "Fatso" with ranking "8"
    And I should see "Fatty" with ranking "8"
    And I should see "Lazy" with ranking "10"
    And I should see "Nogood" with ranking "10"
    And I should not see "Lou"
    And I should not see "Who"
    And I should not see "Loser"

  Scenario: Scoreboard on home page
    When I go to the home page
    Then I should see a scoreboard for demo "Alpha"
    And I should see "Phil" with ranking "1"
    And I should see "Tony" with ranking "2"
    And I should see "Sven" with ranking "2"
    And I should see "Vlad" with ranking "4"
    And I should see "Dan" with ranking "5"
    And I should see "Bleh" with ranking "6"
    And I should see "Blobby" with ranking "6"
    And I should see "Fatso" with ranking "8"
    And I should see "Fatty" with ranking "8"
    And I should see "Lazy" with ranking "10"
    And I should see "Nogood" with ranking "10"
    And I should not see "Lou"
    And I should not see "Who"
    And I should not see "Loser"
