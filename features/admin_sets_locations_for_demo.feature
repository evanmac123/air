Feature: Admin sets up locations for demo

  Scenario: Admin sets up locations for demo
    Given the following demo exists:
      | name |
      | LocatoCo     |
    When I sign in via the login page as an admin
    And I go to the admin "LocatoCo" demo page
    And I follow "Locations for this demo"
    Then I should see "No locations set for this demo"

    When I fill in "Name" with "South Pole"
    And I press "Create Location"
    Then I should be on the admin "LocatoCo" locations page
    And I should see "South Pole"

    When I fill in "Name" with "North Pole"
    And I press "Create Location"
    Then I should be on the admin "LocatoCo" locations page
    And I should see "North Pole"

    When I press "Destroy South Pole"
    Then I should be on the admin "LocatoCo" locations page
    And I should see "North Pole"
    But I should not see "South Pole"
