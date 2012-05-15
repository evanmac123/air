Feature: Admin edits task

  Background:
    Given the following demo exists:
      | name |
      | TaskCo       |
    And the following tasks exist:
      | name               | start time          | demo                 |
      | bake bread         |                     | name: TaskCo |
      | discover fire      |                     | name: TaskCo |
      | domesticate cattle |                     | name: TaskCo |
      | make toast         | 2015-05-01 00:00:00 | name: TaskCo |
    And the task "make toast" has prerequisite "bake bread"
    And the task "make toast" has prerequisite "discover fire"
    And I sign in via the login page as an admin
    And I go to the admin tasks page for "TaskCo"


  Scenario: Admin edits task
    When I follow "make toast"
    And I fill in "Name" with "Make roast beef"
    And I fill in "Short description" with "Cook cow flesh"
    And I fill in "Long description" with "Scorch up the muscle of a beef"
    And I unselect "bake bread" from "Prerequisite tasks"
    And I select "domesticate cattle" from "Prerequisite tasks"
    And I set the task start time to "April/17/2012/3 PM/25"
    And I press "Update Task"

    Then I should not see "make toast"
    But I should see "Make roast beef"

  Scenario: Editing completion triggers should do what you would expect
    Given the following rules exist:
      | reply | demo                 |
      | did 1 | name: TaskCo |
      | did 2 | name: TaskCo |
    And the following rule values exist:
      | value | is primary | rule         |
      | do 1  | true       | reply: did 1 |
      | do 2  | true       | reply: did 2 |
    And the following surveys exist:
      | name     | demo                 |
      | Survey 1 | name: TaskCo |
      | Survey 2 | name: TaskCo |

    When I follow "make toast"
    And I select "do 1" from "Rules"
    And I select "Survey 1" from "Survey"
    And I press "Update Task"
    Then I should see "make toast"
    And I should see "discover fire"
    And I should see "May 01, 2015 @ 12:00 AM"
    And I should see "do 1"
    And I should see "Survey 1"
    
    When I follow "make toast"
    And I select "do 2" from "Rules"
    And I select "Survey 2" from "Survey"
    And I press "Update Task"
    Then I should see "make toast"
    And I should see "discover fire"
    And I should see "May 01, 2015 @ 12:00 AM"
    And I should see "do 2"
    And I should see "Survey 2"