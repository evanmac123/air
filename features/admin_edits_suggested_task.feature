Feature: Admin edits suggested task

  Scenario: Admin edits suggested task
    Given the following demo exists:
      | company name |
      | TaskCo       |
    And the following suggested tasks exist:
      | name               | start time          | demo                 |
      | bake bread         |                     | company_name: TaskCo |
      | discover fire      |                     | company_name: TaskCo |
      | domesticate cattle |                     | company_name: TaskCo |
      | make toast         | 2015-05-01 00:00:00 | company_name: TaskCo |
    And the task "make toast" has prerequisite "bake bread"
    And the task "make toast" has prerequisite "discover fire"
    And the following site admin exists:
      | name | demo                 |
      | Bob  | company_name: TaskCo |
    And "Bob" has the password "foo"
    And I sign in via the login page with "Bob/foo"
    And I go to the admin suggested tasks page for "TaskCo"

    Then I should see "make toast Start time: May 01, 2015 at 12:00 AM Eastern Prerequisites: bake bread discover fire"

    When I click the link to edit the task "make toast"
    And I fill in "Name" with "Make roast beef"
    And I fill in "Short description" with "Cook cow flesh"
    And I fill in "Long description" with "Scorch up the muscle of a beef"
    And I unselect "bake bread" from "Prerequisite tasks"
    And I select "domesticate cattle" from "Prerequisite tasks"
    And I set the suggested task start time to "April/17/2012/3 PM/25"
    And I press "Update Suggested task"

    Then I should not see "make toast"
    And I should not see "Start time: May 01, 2015 at 12:00 AM Eastern"
    And I should not see "Prerequisites: bake bread discover fire"

    But I should see "Make roast beef Cook cow flesh Scorch up the muscle of a beef Start time: April 17, 2012 at 03:25 PM Eastern Prerequisites: discover fire domesticate cattle"
