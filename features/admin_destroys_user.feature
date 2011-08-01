Feature: Admin destroys a user

  Scenario: Admin destroys a user
    Given the following users exist:
      | name | email           | phone number | demo                |
      | Vlad | vlad@engage.com | +16175551212 | company name: FooCo |
    When I sign in as an admin via the login page
    And I go to the admin "FooCo" demo page
    Then I should see "1 users have added mobile numbers"
    When I follow "(edit Vlad)"
    And I press "Destroy user"
    Then I should be on the admin "FooCo" demo page
    And I should see "All records on Vlad destroyed"
    And I should see "0 users have added mobile numbers"
    And I should not see "vlad@hengage.com"
