Feature: Admin sets up suggested tasks
  Background:
    Given the following demo exists:
      | company name |
      | TaskCo       |
    And the following site admin exists:
      | name |
      | Vlad |
    And "Vlad" has the password "foo"
    And I sign in via the login page with "Vlad/foo"
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
    And I should see "Make toast Earn points and enjoy a toasty treat Toast is a foodstuff that millions have enjoyed since the invention of fire."
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
    And I should see "Make toast Earn points and enjoy a toasty treat Toast is a foodstuff that millions have enjoyed since the invention of fire. Prerequisites: Bake bread Discover fire"

  Scenario: Admin adds first-level suggested task with start time
    When I fill in "Name" with "Make toast"
    And I fill in "Short description" with "Earn points and enjoy a toasty treat"
    And I fill in "Long description" with "Toast is a foodstuff that millions have enjoyed since the invention of fire."
    And I set the suggested task start time to "May/1/2015/12 AM/00/00"
    And I press "Create Suggested task"
    Then I should be on the admin suggested tasks page for "TaskCo"
    And I should see "Make toast Earn points and enjoy a toasty treat Toast is a foodstuff that millions have enjoyed since the invention of fire. Start time: May 01, 2015 at 12:00 AM Eastern"

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
    And I should see "Make toast Earn points and enjoy a toasty treat Toast is a foodstuff that millions have enjoyed since the invention of fire. Start time: May 01, 2015 at 12:00 AM Eastern Prerequisites: Bake bread Discover fire"
