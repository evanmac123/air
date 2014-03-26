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
    And the following user exists:
      | name | email           | demo                |
      | Joe  | joe@example.com | name: FooCo |
    And "Joe" has the password "foobar"
    And I sign in via the login page with "Joe/foobar"

  Scenario: User sees tiles they can currently do
    Then I should see the "Make toast" tile
    And I should see the "Butter toast" tile
    And I should see the "Eat buttery toast" tile
    And I should see the "Make PBJ" tile

  Scenario: User doesn't see tiles they can't currently do
    Then I should not see the "Make future toast" tile
    And I should not see the "Make future PBJ" tile
    When time is frozen at "2020-01-01 00:00:01 UTC"
    And DJ works off
    And I sign in via the login page with "Joe/foobar"
    And I go to the activity page
    Then I should see the "Make future toast" tile
    And I should see the "Make future PBJ" tile
    But I should not see the "Think past toast" tile
    And I should not see the "Think past PBJ" tile
