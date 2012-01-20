Feature: User sees suggested tasks they can currently do

  Background:
    Given the following demo exists:
      | company name |
      | FooCo        |
    And the following suggested tasks exist:
      | name              | short description | long description                                  | start time       | demo                |
      | Make toast        | Toast some bread  | Turn bread into toast by the application of fire. |                      | company_name: FooCo |
      | Make PBJ          | Spread PB and J   | Put peanut butter and jelly on bread              |                      | company_name: FooCo |
      | Butter toast      | Butter it up      | No peanut butter just regular butter this time    |                      | company_name: FooCo |
      | Plate toast       | Put it on a plate | Were you born in a barn?                          |                      | company_name: FooCo |
      | Eat buttery toast | Eat it up yum     | It's bad for your arteries though                 |                      | company_name: FooCo |
      | Make future toast | Space toast!      | Make toast using lasers and shit                  | 2030-01-01 00:00 UTC | company_name: FooCo |
      | Make future PBJ   | Space PBJ!        | Make PBJ using lasers and shit                    | 2030-01-01 00:00 UTC | company_name: FooCo |
    And the task "Make PBJ" has prerequisite "Make toast"
    And the task "Butter toast" has prerequisite "Make toast"
    And the task "Eat buttery toast" has prerequisite "Butter toast"
    And the task "Eat buttery toast" has prerequisite "Plate toast"
    And the task "Make future PBJ" has prerequisite "Make future toast"
    And the following user exists:
      | name | email           | demo                |
      | Joe  | joe@example.com | company_name: FooCo |
    And "Joe" has the password "foobar"
    And I sign in via the login page with "Joe/foobar"

  @javascript @slow @wip
  Scenario: User sees suggested tasks they can currently do
    Then I should see "Make toast"
    And I should see "Toast some bread"
    But "Turn bread into toast by the application of fire." should not be visible
    When I follow "More info"
    Then "Turn bread into toast by the application of fire." should be visible

  Scenario: User doesn't see suggested tasks they can't currently do
    Then I should not see "Make PBJ"
    And I should not see "Make future toast"
    And I should not see "Make future PBJ"
    But I should see "Plate toast"

    When time is frozen at "2030-01-01 00:00:01 UTC"
    And DJ cranks 10 times
    And I sign in via the login page with "Joe/foobar"
    And I go to the activity page
    Then I should see "Make future toast"
    But I should not see "Make future PBJ"
    And I should not see "Make PBJ"
    And I should not see "Butter toast"
    And I should not see "Eat buttery toast"

  Scenario: User doesn't see suggested task they've already done
    When "Joe" satisfies suggested task "Make toast"
    And I go to the activity page
    Then I should not see "Make toast"

  Scenario: User, after completing a task, sees tasks they can now do
    When "Joe" satisfies suggested task "Make toast"
    And I go to the activity page
    Then I should see "Make PBJ"
    And I should see "Butter toast"
    But I should not see "Eat buttery toast"

    When "Joe" satisfies suggested task "Butter toast"
    And I go to the activity page
    Then I should not see "Eat buttery toast"

    When "Joe" satisfies suggested task "Plate toast"
    And I go to the activity page
    Then I should see "Eat buttery toast"

  Scenario: Newly created suggested task shows up for users who are eligible for it
    When I sign in via the login page as an admin
    And I go to the admin "FooCo" demo page
    And I follow "Suggested tasks for this demo"
    And I follow "Add suggested task"
    And I fill in "Name" with "Do new stuff"
    And I press "Create Suggested task"
    And DJ cranks 10 times

    And I sign in via the login page with "Joe/foobar"
    Then I should see "Do new stuff"

  Scenario: Newly created user sees suggested tasks they can do
    Given the following user exists:
      | name | email           | demo                |
      | Bob  | bob@example.com | company_name: FooCo |
    And "Bob" has the password "barbaz"
    And I sign in via the login page with "Bob/barbaz"
    Then I should be on the activity page
    And I should see "Make toast"
    But I should not see "Make PBJ"
    And I should not see "Make future toast"
    And I should not see "Make future PBJ"
    And I should not see "Butter toast"
    And I should not see "Eat buttery toast"

    When time is frozen at "2030-01-01 00:00:01 UTC"
    And DJ cranks 10 times
    And I sign in via the login page with "Bob/barbaz"
    And I go to the activity page
    Then I should see "Make future toast"
    But I should not see "Make future PBJ"
    And I should not see "Make PBJ"
