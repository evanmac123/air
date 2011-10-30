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
      | Loser  | 1      | company_name: Alpha | 
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
      | Artur  | 81     | company_name: Alpha |
      | Lulu   | 80     | company_name: Alpha |
      | Sadie  | 79     | company_name: Alpha |
      | Smalls | 78     | company_name: Alpha |
      | Jerry  | 77     | company_name: Alpha |
      | Patsy  | 76     | company_name: Alpha |
      | Who    | 200    | company_name: Enron | 

    And the following friendships exist:
      | user       | friend       |
      | name: Lazy | name: Phil   |
      | name: Lazy | name: Sven   |
      | name: Lazy | name: Dan    |
      | name: Lazy | name: Blobby |
      | name: Lazy | name: Fatty  |
      | name: Lazy | name: Nogood |
      | name: Lazy | name: Rufus  |
      | name: Lazy | name: Jan    |
      | name: Lazy | name: Mikey  |
      | name: Lazy | name: Bert   |
      | name: Lazy | name: Kitty  |
      | name: Lazy | name: Irene  |
      | name: Lazy | name: Jess   |
      | name: Lazy | name: Artur  |
      | name: Lazy | name: Sadie  |
      | name: Lazy | name: Jerry  |
      | name: Lazy | name: Loser  |

    And "Lazy" has the password "foobar"
    And I sign in via the login page as "Lazy/foobar"

  @javascript
  Scenario: Scoreboard on acts page
    When I go to the acts page
    Then I should see a scoreboard for demo "Alpha"
     And "All" should be the active scoreboard filter link
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
    And I should not see "Mikey"
    And I should not see "Rudy"
    And I should not see "Bert"
    And I should not see "Charly"
    And I should not see "Kitty"
    And I should not see "Stacey"
    And I should not see "Irene"
    And I should not see "Donna"
    And I should not see "Jess"
    And I should not see "Lucas"
    And I should not see "Lou"
    And I should not see "Who"
    And I should not see "Loser"
    And I should not see "Artur"
    And I should not see "Lulu"
    And I should not see "Sadie"
    And I should not see "Smalls"
    And I should not see "Jerry"
    And I should not see "Patsy"

    When I press the "see more" button in the scoreboard
    Then I should see the following user rankings:      
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
      | Lucas  | 26      |
      | Artur  | 27      |
      | Lulu   | 28      |
      | Sadie  | 29      |
      | Smalls | 30      |
      | Jerry  | 31      |
      | Patsy  | 32      |
      | Loser  | 33      |

    When I follow "Fan Of" in the scoreboard tabs
    Then "Fan Of" should be the active scoreboard filter link
    And I should see the following user rankings:
      | name   | ranking |
      | Phil   | 1       |
      | Sven   | 2       |
      | Dan    | 5       |
      | Blobby | 6       |
      | Fatty  | 8       |
      | Nogood | 10      |
      | Rufus  | 13      | 
      | Jan    | 15      | 
    And I should not see "Mikey"
    And I should not see "Bert"
    And I should not see "Kitty"
    And I should not see "Irene"
    And I should not see "Jess"
    And I should not see "Artur"
    And I should not see "Sadie"
    And I should not see "Tony"
    And I should not see "Vlad"
    And I should not see "Bleh"
    And I should not see "Fatso"
    And I should not see "Fred"
    And I should not see "Paula"
    And I should not see "Gaston"
    And I should not see "Rudy"
    And I should not see "Charly"
    And I should not see "Stacey"
    And I should not see "Donna"
    And I should not see "Lucas"
    And I should not see "Lulu"
    And I should not see "Smalls"
    And I should not see "Patsy"
    And I should not see "Loser"
    And I should not see "Jerry"

    When I press the "see more" button in the scoreboard    
    Then I should see the following user rankings:
      | name   | ranking |
      | Phil   | 1       |
      | Sven   | 2       |
      | Dan    | 5       |
      | Blobby | 6       |
      | Fatty  | 8       |
      | Nogood | 10      |
      | Rufus  | 13      | 
      | Jan    | 15      | 
      | Mikey  | 17      | 
      | Bert   | 19      | 
      | Kitty  | 21      | 
      | Irene  | 23      | 
      | Jess   | 24      | 
      | Artur  | 27      |
      | Sadie  | 29      |
      | Jerry  | 31      |
      | Loser  | 33      |

    And I should not see "Tony"
    And I should not see "Vlad"
    And I should not see "Bleh"
    And I should not see "Fatso"
    And I should not see "Fred"
    And I should not see "Paula"
    And I should not see "Gaston"
    And I should not see "Rudy"
    And I should not see "Charly"
    And I should not see "Stacey"
    And I should not see "Donna"
    And I should not see "Lucas"
    And I should not see "Lulu"
    And I should not see "Smalls"
    And I should not see "Patsy"

    When I follow "All" in the scoreboard tabs
    Then "All" should be the active scoreboard filter link
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
    And I should not see "Mikey"
    And I should not see "Rudy"
    And I should not see "Bert"
    And I should not see "Charly"
    And I should not see "Kitty"
    And I should not see "Stacey"
    And I should not see "Irene"
    And I should not see "Donna"
    And I should not see "Jess"
    And I should not see "Lucas"
    And I should not see "Lou"
    And I should not see "Who"
    And I should not see "Loser"
    And I should not see "Artur"
    And I should not see "Lulu"
    And I should not see "Sadie"
    And I should not see "Smalls"
    And I should not see "Jerry"
    And I should not see "Patsy"

    When I press the "see more" button in the scoreboard
    Then I should see the following user rankings:      
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
      | Lucas  | 26      |
      | Artur  | 27      |
      | Lulu   | 28      |
      | Sadie  | 29      |
      | Smalls | 30      |
      | Jerry  | 31      |
      | Patsy  | 32      |
      | Loser  | 33      |

