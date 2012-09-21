Feature: Admin edits tile

  Background:
    Given the following demo exists:
      | name |
      | TileCo       |
    And the following tiles exist:
      | name               | start time              | demo         |
      | bake bread         |                         | name: TileCo |
      | discover fire      |                         | name: TileCo |
      | domesticate cattle |                         | name: TileCo |
      | make toast         | 2015-05-01 08:00:00 UTC | name: TileCo |
    And the tile "make toast" has prerequisite "bake bread"
    And the tile "make toast" has prerequisite "discover fire"
    And I sign in via the login page as an admin
    And I go to the admin tiles page for "TileCo"


  Scenario: Admin edits tile
    When I follow "make toast"
    And I fill in "Name" with "Make roast beef"
    And I unselect "bake bread" from "Prerequisite tiles"
    And I select "domesticate cattle" from "Prerequisite tiles"
    And I fill in "Start time" with "April 17,2012 3:25 PM"
    And I press "Update Tile"

    Then I should not see "make toast"
    But I should see "Make roast beef"
    And I should see "domesticate cattle"
    And I should see "Apr 17, 2012 @ 03:25 PM"

  Scenario: Editing completion triggers should do what you would expect
    Given the following rules exist:
      | reply | demo                 |
      | did 1 | name: TileCo |
      | did 2 | name: TileCo |
    And the following rule values exist:
      | value | is primary | rule         |
      | do 1  | true       | reply: did 1 |
      | do 2  | true       | reply: did 2 |
    And the following surveys exist:
      | name     | demo                 |
      | Survey 1 | name: TileCo |
      | Survey 2 | name: TileCo |

    When I follow "make toast"
    And I choose "tile_poly_true"
    And I select "do 1" from "Rules"
    And I select "Survey 1" from "Survey"
    And I press "Update Tile"
    Then I should see "make toast"
    And I should see "discover fire"
    And I should see "May 01, 2015 @ 04:00 AM"
    And I should see "do 1"
    And I should see "Survey 1"
    
    When I follow "make toast"
    And I select "do 2" from "Rules"
    And I select "Survey 2" from "Survey"
    And I press "Update Tile"
    Then I should see "make toast"
    And I should see "discover fire"
    And I should see "May 01, 2015 @ 04:00 AM"
    And I should see "do 2"
    And I should see "Survey 2"
