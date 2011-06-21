Feature: Scoreboard

  Background:
    Given the following user exists:
      | name   | points | demo                |
      | Lou    | 1      | company_name: Alpha |
    And the following user with phones exist:
      | name   | points | demo                | 
      | Lazy   | 94     | company_name: Alpha | 
      | Nogood | 94     | company_name: Alpha | 
      | Tony   | 100    | company_name: Alpha | 
      | Bleh   | 96     | company_name: Alpha | 
      | Phil   | 634923 | company_name: Alpha | 
      | Vlad   | 98     | company_name: Alpha | 
      | Dan    | 97     | company_name: Alpha | 
      | Sven   | 100    | company_name: Alpha | 
      | Loser  | 0      | company_name: Alpha | 
      | Blobby | 96     | company_name: Alpha | 
      | Fatso  | 95     | company_name: Alpha | 
      | Fatty  | 95     | company_name: Alpha |
      | Fred   | 93     | company_name: Alpha |
      | Rufus  | 92     | company_name: Alpha |
      | Paula  | 91     | company_name: Alpha |
      | Jan    | 90     | company_name: Alpha |
      | Gaston | 90     | company_name: Alpha |
      | Mikey  | 89     | company_name: Alpha |
      | Rudy   | 88     | company_name: Alpha |
      | Bert   | 87     | company_name: Alpha |
      | Charly | 86     | company_name: Alpha |
      | Kitty  | 85     | company_name: Alpha |
      | Stacey | 85     | company_name: Alpha |
      | Irene  | 84     | company_name: Alpha |
      | Donna  | 83     | company_name: Alpha |
      | Jess   | 83     | company_name: Alpha |
      | Lucas  | 82     | company_name: Alpha |
      | Who    | 200    | company_name: Enron | 
    And "Lazy" has the password "foobar"
    And I sign in via the login page as "Lazy/foobar"

  Scenario: Scoreboard on acts page
    When I go to the acts page
    Then I should see a scoreboard for demo "Alpha"
    And I should see the following user rankings:
      | name   | ranking |
      | Phil   | 1       |
      | Tony   | 2       |
      | Sven   | 2       |
      | Vlad   | 4       |
      | Dan    | 5       |
      | Bleh   | 6       |
      | Blobby | 6       |
      | Fatso  | 8       |
      | Fatty  | 8       |
      | Lazy   | 10      |
      | Nogood | 10      |
      | Fred   | 12      | 
      | Rufus  | 13      | 
      | Paula  | 14      | 
      | Jan    | 15      | 
      | Gaston | 15      | 
      | Mikey  | 17      | 
      | Rudy   | 18      | 
      | Bert   | 19      | 
      | Charly | 20      | 
      | Kitty  | 21      | 
      | Stacey | 21      | 
      | Irene  | 23      | 
      | Donna  | 24      | 
      | Jess   | 24      | 
    And I should not see "Lucas"
    And I should not see "Lou"
    And I should not see "Who"
    And I should not see "Loser"

  Scenario: Scoreboard on home page
    When I go to the home page
    Then I should see a scoreboard for demo "Alpha"
    And I should see the following user rankings:
      | name   | ranking |
      | Phil   | 1       |
      | Tony   | 2       |
      | Sven   | 2       |
      | Vlad   | 4       |
      | Dan    | 5       |
      | Bleh   | 6       |
      | Blobby | 6       |
      | Fatso  | 8       |
      | Fatty  | 8       |
      | Lazy   | 10      |
      | Nogood | 10      |
      | Fred   | 12      | 
      | Rufus  | 13      | 
      | Paula  | 14      | 
      | Jan    | 15      | 
      | Gaston | 15      | 
      | Mikey  | 17      | 
      | Rudy   | 18      | 
      | Bert   | 19      | 
      | Charly | 20      | 
      | Kitty  | 21      | 
      | Stacey | 21      | 
      | Irene  | 23      | 
      | Donna  | 24      | 
      | Jess   | 24      | 
    And I should not see "Lucas"
    And I should not see "Lou"
    And I should not see "Who"
    And I should not see "Loser"
