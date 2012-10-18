Feature: Admin sets up tiles
  Background:
    Given a fresh start
    Given the following demo exists:
      | name |
      | TileCo       |
    And the following rules exist:
      | reply              | demo                 |
      | you did 1          | name: TileCo |
      | you did 2          | name: TileCo |
      | you did 3          | name: TileCo |
      | you did 4 anywhere |                      |
    And the following rule values exist:
      | value       | is_primary | rule                      |
      | did thing 1 | true       | reply: you did 1          |
      | did thing 2 | true       | reply: you did 2          |
      | did thing 3 | true       | reply: you did 3          |
      | did thing 4 | true       | reply: you did 4 anywhere |
    And the following surveys exist:
      | name        | demo                 |
      | Survey 1    | name: TileCo |
      | Survey 2    | name: TileCo |
    And I sign in via the login page as an admin
    And I go to the admin "TileCo" demo page
    And I follow "Tiles for this demo"
    Then I should be on the admin tiles page for "TileCo"
    And I should see "No tiles for this demo"

    When I follow "Add tile"

  Scenario: Admin adds first-level tile
    When I fill in "Identifier" with "ident1"
    When I fill in "Headline" with "Make toast"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"

    Then I should be on the admin tiles page for "TileCo"
    And I should see "Make toast"

  Scenario: Admin adds tile with prerequisites
    When I fill in "Identifier" with "ident1"
    When I fill in "Headline" with "Discover fire"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"
    And I follow "Add tile"
    When I fill in "Identifier" with "ident2"
    And I fill in "Headline" with "Bake bread"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"
    
    And I follow "Add tile"
    When I fill in "Identifier" with "ident2"
    When I fill in "Headline" with "Make toast"
    When I fill in "Identifier" with "ident3"
    And I select "Bake bread" from "Prerequisite tiles"
    And I select "Discover fire" from "Prerequisite tiles"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"

    Then I should be on the admin tiles page for "TileCo"
    And I should see "Make toast"

  Scenario: Admin adds first-level tile with start and end time
    When I fill in "Identifier" with "ident1"
    When I fill in "Headline" with "Make toast"
    And I fill in "Start time" with "5/1/2015, 12:00 AM"
    And I fill in "End time" with "8/5/2015, 12:00 PM"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"
    Then I should be on the admin tiles page for "TileCo"
    And I should see "Make toast"
    And I should see "May 01, 2015 @ 12:00 AM"
    And I should see "Aug 05, 2015 @ 12:00 PM"

  Scenario: Admin adds tile with prerequisites and start time
    When I fill in "Identifier" with "ident1"
    When I fill in "Headline" with "Discover fire"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"
    And I follow "Add tile"
    When I fill in "Identifier" with "ident2"
    And I fill in "Headline" with "Bake bread"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"
    
    And I follow "Add tile"
    When I fill in "Identifier" with "ident3"
    When I fill in "Headline" with "Make toast"
    And I select "Bake bread" from "Prerequisite tiles"
    And I select "Discover fire" from "Prerequisite tiles"
    And I fill in "Start time" with "5-1-2015, 12:00 AM"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"

    Then I should be on the admin tiles page for "TileCo"
    And I should see "Make toast"
    And I should see "May 01, 2015 @ 12:00 AM"
    
  Scenario: Admin adds tile with rule completion trigger
    When I fill in "Identifier" with "ident1"
    
    When I fill in "Headline" with "Do thing 2"
    And I select "did thing 2" from "Rules"
    And I select "did thing 4" from "Rules"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"
    Then I should be on the admin tiles page for "TileCo"
    And I should not see "Manual only"

  Scenario: Admin adds tile with rule completion trigger and referer required
    When I fill in "Identifier" with "ident1"
  
    When I fill in "Headline" with "Do thing 2"
    And I select "did thing 2" from "Rules"
    And I select "did thing 4" from "Rules"
    And I check "Referrer required"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"
    Then I should be on the admin tiles page for "TileCo"
    And I should see "Do thing 2"
    And I should see "Rules (any of the following, referrer required)"
    And I should see "did thing 2"
    And I should see "did thing 4"
    And I should not see "Manual only"

  Scenario: Admin adds tile with survey trigger
    When I fill in "Identifier" with "ident1"
    When I fill in "Headline" with "Complete survey 1"
    And I select "Survey 1" from "Survey"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"
    Then I should be on the admin tiles page for "TileCo"
    And I should see "Complete survey 1"
    And I should see "Survey: Survey 1"
    And I should not see "Manual only"

  Scenario: Admin adds tile with demographic trigger
    When I fill in "Identifier" with "ident1"
    When I fill in "Headline" with "Complete demographics"
    And I check "Complete by filling in all demographics"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"
    Then I should be on the admin tiles page for "TileCo"
    And I should see "Complete demographics"
    And I should not see "Manual only"
