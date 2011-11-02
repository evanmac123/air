Feature: Admin adds user

  Scenario: Admin adds user
    Given the following demo exists:
      | company name  |
      | The H Engages |
    When I sign in as an admin via the login page
    And I go to the admin "The H Engages" demo page
    And I fill in "Name" with "Vlad Gyster"
    And I fill in "Email" with "vlad@hengage.com"
    And I check "Set claim code"
    And I press "Submit"
    Then I should be on the admin "The H Engages" demo page

    When I follow "V"
    Then I should see "Vlad Gyster, vlad@hengage.com (vgyster)"

  Scenario: Admin tries adding duplicate user and gets a reasonable error message
    Given the following user exists:
      | name        | email            | demo                        |
      | Vlad Gyster | vlad@hengage.com | company name: The H Engages |    
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
