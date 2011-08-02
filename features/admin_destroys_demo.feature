Feature: Admin destroys demo

  Scenario: Admin destroys demo
    Given the following demos exist:
      | company name |
      | FooCo        |
      | BarCo        |
    When I sign in as an admin via the login page
    When I go to the admin "FooCo" demo page
    And I press "Destroy game"
    Then I should be on the admin page
    And I should see "FooCo game destroyed"
    When I go to the admin page
    Then I should see "BarCo"
    And I should not see "FooCo"
