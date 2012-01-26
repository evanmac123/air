Feature: Admin adds user

  Scenario: Admin adds user
    Given the following demo exists:
      | name  |
      | The H Engages |
    When I sign in as an admin via the login page
    And I go to the admin "The H Engages" demo page
    And I fill in "Name" with "Vlad Gyster"
    And I fill in "Email" with "vlad@hengage.com"
    And I should not see a form field called "Location"
    And I check "Set claim code"
    And I press "Submit"
    Then I should be on the admin "The H Engages" demo page

    When I follow "V"
    Then I should see "Vlad Gyster, vlad@hengage.com (vgyster)"

  Scenario: Admin tries adding duplicate user and gets a reasonable error message
    Given the following user exists:
      | name        | email            | demo                        |
      | Vlad Gyster | vlad@hengage.com | name: The H Engages |    
    When I sign in as an admin via the login page
    And I go to the admin "The H Engages" demo page
    And I fill in "Name" with "Vlad O'Reilly"
    And I fill in "Email" with "vlad@hengage.com"
    And I press "Submit"
    Then I should be on the admin "The H Engages" demo page
    And I should see "Cannot create that user: Email has already been taken"

    When I follow "V"
    Then I should see "Vlad Gyster, vlad@hengage.com"
    And I should not see "Vlad O'Reilly"

  Scenario: Admin adds user to a demo with locations
    Given the following demo exists:
      | name  |
      | DistributedCo |
    And the following locations exist:
      | name         | demo                        |
      | First Plant  | name: DistributedCo | 
      | Second Plant | name: DistributedCo | 
      | Third Plant  | name: DistributedCo | 
    When I sign in as an admin via the login page
    And I go to the admin "DistributedCo" demo page
    
    When I fill in "Name" with "Vlad Gyster"
    And I fill in "Email" with "vlad@hengage.com"
    And I check "Set claim code"
    And I select "Second Plant" from "Location"
    And I press "Submit"
    
    Then I should be on the admin "DistributedCo" demo page
    When I follow "V"
    Then I should see "Vlad Gyster, vlad@hengage.com (vgyster) (location: Second Plant)"

