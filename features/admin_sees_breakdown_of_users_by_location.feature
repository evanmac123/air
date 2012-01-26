Feature: Admin sees breakdown of users by location
  
  Scenario: Admin sees breakdown of users by location
    Given the following demo exists:
      | name |
      | LocatoCo     |
    And the following locations exist:
      | name       | demo                   |
      | Whoville   | name: LocatoCo |
      | North Pole | name: LocatoCo |
      | Detroit    | name: LocatoCo |
      | Emptyville | name: LocatoCo |
    And the following users exist:
      | location         | demo                   |
      | name: North Pole | name: LocatoCo |
      | name: Detroit    | name: LocatoCo |
      | name: Detroit    | name: LocatoCo |
      | name: North Pole | name: LocatoCo |
      | name: Whoville   | name: LocatoCo |
      | name: North Pole | name: LocatoCo |
    When I sign in via the login page as an admin
    And I go to the admin "LocatoCo" user-by-location page
    Then I should see "Detroit 2 Emptyville 0 North Pole 3 Whoville 1"
