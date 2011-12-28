Feature: Admin edits suggested task

  Background:
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
    And I sign in via the login page as an admin
    And I go to the admin suggested tasks page for "TaskCo"

    Then I should see "make toast Start time: May 01, 2015 at 12:00 AM Eastern Prerequisites: bake bread discover fire"

  Scenario: Admin edits suggested task
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

  Scenario: Editing completion triggers should do what you would expect
    Given the following rules exist:
      | reply | demo                 |
      | did 1 | company_name: TaskCo |
      | did 2 | company_name: TaskCo |
    And the following rule values exist:
      | value | is primary | rule         |
      | do 1  | true       | reply: did 1 |
      | do 2  | true       | reply: did 2 |
    And the following surveys exist:
      | name     | demo                 |
      | Survey 1 | company_name: TaskCo |
      | Survey 2 | company_name: TaskCo |

    When I click the link to edit the task "make toast"
    And I select "do 1" from "Rules"
    And I select "Survey 1" from "Survey"
    And I press "Update Suggested task"
    Then I should see "make toast Start time: May 01, 2015 at 12:00 AM Eastern Prerequisites: bake bread discover fire Rules (any of the following): do 1 Survey: Survey 1"    
    
    When I click the link to edit the task "make toast"
    And I select "do 2" from "Rules"
    And I select "Survey 2" from "Survey"
    And I press "Update Suggested task"
    Then I should see "make toast Start time: May 01, 2015 at 12:00 AM Eastern Prerequisites: bake bread discover fire Rules (any of the following): do 1 do 2 Survey: Survey 2"
