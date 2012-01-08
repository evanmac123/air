Feature: Admin sets up suggested tasks
  Background:
    Given the following demo exists:
      | company name |
      | TaskCo       |
    And the following rules exist:
      | reply              | demo                 |
      | you did 1          | company_name: TaskCo |
      | you did 2          | company_name: TaskCo |
      | you did 3          | company_name: TaskCo |
      | you did 4 anywhere |                      |
    And the following rule values exist:
      | value       | is_primary | rule                      |
      | did thing 1 | true       | reply: you did 1          |
      | did thing 2 | true       | reply: you did 2          |
      | did thing 3 | true       | reply: you did 3          |
      | did thing 4 | true       | reply: you did 4 anywhere |
    And the following surveys exist:
      | name        | demo                 |
      | Survey 1    | company_name: TaskCo |
      | Survey 2    | company_name: TaskCo |
    And I sign in via the login page as an admin
    And I go to the admin "TaskCo" demo page
    And I follow "Suggested tasks for this demo"
    Then I should be on the admin suggested tasks page for "TaskCo"
    And I should see "No suggested tasks for this demo"

    When I follow "Add suggested task"

  Scenario: Admin adds first-level suggested task
    When I fill in "Name" with "Make toast"
    And I fill in "Short description" with "Earn points and enjoy a toasty treat"
    And I fill in "Long description" with "Toast is a foodstuff that millions have enjoyed since the invention of fire."
    And I press "Create Suggested task"

    Then I should be on the admin suggested tasks page for "TaskCo"
    And I should see "Make toast Earn points and enjoy a toasty treat Toast is a foodstuff that millions have enjoyed since the invention of fire. Manual only."
    And I should not see "Prerequisites"

  Scenario: Admin adds suggested task with prerequisites
    When I fill in "Name" with "Discover fire"
    And I press "Create Suggested task"
    And I follow "Add suggested task"
    And I fill in "Name" with "Bake bread"
    And I press "Create Suggested task"
    
    And I follow "Add suggested task"
    When I fill in "Name" with "Make toast"
    And I fill in "Short description" with "Earn points and enjoy a toasty treat"
    And I fill in "Long description" with "Toast is a foodstuff that millions have enjoyed since the invention of fire."
    And I select "Bake bread" from "Prerequisite tasks"
    And I select "Discover fire" from "Prerequisite tasks"
    And I press "Create Suggested task"

    Then I should be on the admin suggested tasks page for "TaskCo"
    And I should see "Make toast Earn points and enjoy a toasty treat Toast is a foodstuff that millions have enjoyed since the invention of fire. Prerequisites: Bake bread Discover fire Manual only."

  Scenario: Admin adds first-level suggested task with start time
    When I fill in "Name" with "Make toast"
    And I fill in "Short description" with "Earn points and enjoy a toasty treat"
    And I fill in "Long description" with "Toast is a foodstuff that millions have enjoyed since the invention of fire."
    And I set the suggested task start time to "May/1/2015/12 AM/00/00"
    And I press "Create Suggested task"
    Then I should be on the admin suggested tasks page for "TaskCo"
    And I should see "Make toast Earn points and enjoy a toasty treat Toast is a foodstuff that millions have enjoyed since the invention of fire. Start time: May 01, 2015 at 12:00 AM Eastern Manual only."

  Scenario: Admin adds suggested task with prerequisites and start time
    When I fill in "Name" with "Discover fire"
    And I press "Create Suggested task"
    And I follow "Add suggested task"
    And I fill in "Name" with "Bake bread"
    And I press "Create Suggested task"
    
    And I follow "Add suggested task"
    When I fill in "Name" with "Make toast"
    And I fill in "Short description" with "Earn points and enjoy a toasty treat"
    And I fill in "Long description" with "Toast is a foodstuff that millions have enjoyed since the invention of fire."
    And I select "Bake bread" from "Prerequisite tasks"
    And I select "Discover fire" from "Prerequisite tasks"
    And I set the suggested task start time to "May/1/2015/12 AM/00/00"
    And I press "Create Suggested task"

    Then I should be on the admin suggested tasks page for "TaskCo"
    And I should see "Make toast Earn points and enjoy a toasty treat Toast is a foodstuff that millions have enjoyed since the invention of fire. Start time: May 01, 2015 at 12:00 AM Eastern Prerequisites: Bake bread Discover fire Manual only."

  Scenario: Admin adds suggested task with rule completion trigger
    When I fill in "Name" with "Do thing 2"
    And I select "did thing 2" from "Rules"
    And I select "did thing 4" from "Rules"
    And I press "Create Suggested task"
    Then I should be on the admin suggested tasks page for "TaskCo"
    And I should see "Do thing 2 Rules (any of the following): did thing 2 did thing 4"
    And I should not see "Manual only"

  Scenario: Admin adds suggested task with rule completion trigger and referer required
    When I fill in "Name" with "Do thing 2"
    And I select "did thing 2" from "Rules"
    And I select "did thing 4" from "Rules"
    And I check "Referrer required"
    And I press "Create Suggested task"
    Then I should be on the admin suggested tasks page for "TaskCo"
    And I should see "Do thing 2 Rules (any of the following, referrer required): did thing 2 did thing 4"
    And I should not see "Manual only"

  Scenario: Admin adds suggested task with survey trigger
    When I fill in "Name" with "Complete survey 1"
    And I select "Survey 1" from "Survey"
    And I press "Create Suggested task"
    Then I should be on the admin suggested tasks page for "TaskCo"
    And I should see "Complete survey 1 Survey: Survey 1"
    And I should not see "Manual only"

  Scenario: Admin adds suggested task with demographic trigger
    When I fill in "Name" with "Complete demographics"
    And I check "Complete by filling in all demographics"
    And I press "Create Suggested task"
    Then I should be on the admin suggested tasks page for "TaskCo"
    And I should see "Complete demographics Complete demographics"
    And I should not see "Manual only"
