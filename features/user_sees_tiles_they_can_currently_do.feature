Feature: User sees tiles they can currently do

  Background:
    Given the following demo exists:
      | name |
      | FooCo        |
    And the following tiles exist:
      | headline              | start time            | end_time             | demo        | status |
      | Make toast            |                       |                      | name: FooCo | active |
      | Make PBJ              |                       |                      | name: FooCo | active |
      | Butter toast          |                       |                      | name: FooCo | active |
      | Plate toast           |                       |                      | name: FooCo | active |
      | Eat buttery toast     |                       |                      | name: FooCo | active |
      | Make future toast     |  2020-01-01 00:00 UTC |                      | name: FooCo | active |
      | Make future PBJ       |  2020-01-01 00:00 UTC |                      | name: FooCo | active |
      | Think past toast      |                       | 1900-01-01 00:00 UTC | name: FooCo | active |
      | Think past PBJ        |                       | 1900-01-01 00:00 UTC | name: FooCo | active |
    And the tile "Make PBJ" has prerequisite "Make toast"
    And the tile "Butter toast" has prerequisite "Make toast"
    And the tile "Eat buttery toast" has prerequisite "Butter toast"
    And the tile "Eat buttery toast" has prerequisite "Plate toast"
    And the tile "Make future PBJ" has prerequisite "Make future toast"
    And the following user exists:
      | name | email           | demo                |
      | Joe  | joe@example.com | name: FooCo |
    And "Joe" has the password "foobar"
    And I sign in via the login page with "Joe/foobar"

  Scenario: User sees tiles they can currently do
    Then I should see the "Make toast" tile

  Scenario: User doesn't see tiles they can't currently do
    Then I should not see the "Make PBJ" tile
    And I should not see the "Make future toast" tile
    And I should not see the "Make future PBJ" tile
    But I should see the "Plate toast" tile
    When time is frozen at "2020-01-01 00:00:01 UTC"
    And DJ works off
    And I sign in via the login page with "Joe/foobar"
    And I go to the activity page
    Then I should see the "Make future toast" tile
    But I should not see the "Make future PBJ" tile
    And I should not see the "Make PBJ" tile
    And I should not see the "Butter toast" tile
    And I should not see the "Eat buttery toast" tile
    And I should not see the "Think past toast" tile
    And I should not see the "Think past PBJ" tile

  @javascript
  Scenario: User doesn't see tile they've already done
    When "Joe" satisfies tile "Make toast"
    And I go to the activity page
    Then I should not see the "Make toast" tile

  @javascript
  Scenario: User, after completing a tile, sees tiles they can now do
    When "Joe" satisfies tile "Make toast"
    And I go to the activity page
    Then I should see the "Make PBJ" tile
    And I should see the "Butter toast" tile
    But I should not see the "Eat buttery toast" tile
    When "Joe" satisfies tile "Butter toast"
    And I go to the activity page
    Then I should not see the "Eat buttery toast" tile
    When "Joe" satisfies tile "Plate toast"
    And I go to the activity page
    Then I should see the "Eat buttery toast" tile

  Scenario: Newly created tile shows up for users who are eligible for it
    When I sign in via the login page as an admin
    And I go to the admin "FooCo" demo page
    And I follow "Tiles for this demo"
    And I follow "Add tile"
    And I fill in "Headline" with "Do new stuff"
    And I attach an image to the tile
    And I attach a thumbnail to the tile
    And I press "Create Tile"
    And DJ works off
    And I sign in via the login page with "Joe/foobar"
    Then I should see the "Do new stuff" tile

  Scenario: Newly created user sees tiles they can do
    Given the following user exists:
      | name | email           | demo                |
      | Bob  | bob@example.com | name: FooCo |
    And "Bob" has the password "barbaz"
    And I sign in via the login page with "Bob/barbaz"
    Then I should be on the activity page with HTML forced
    And I should see the "Make toast" tile
    But I should not see the "Make PBJ" tile
    And I should not see the "Make future toast" tile
    And I should not see the "Make future PBJ" tile
    And I should not see the "Butter toast" tile
    And I should not see the "Eat buttery toast" tile

    When time is frozen at "2020-01-01 00:00:01 UTC"
    And DJ works off
    And I sign in via the login page with "Bob/barbaz"
    And I go to the activity page
    Then I should see the "Make future toast" tile
    But I should not see the "Make future PBJ" tile
    And I should not see the "Make PBJ" tile
