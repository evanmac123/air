Feature: Admin sees breakdown of users by location
  
  Scenario: Admin sees breakdown of users by location
    Given the following demo exists:
      | company name |
      | LocatoCo     |
    And the following locations exist:
      | name       | demo                   |
      | Whoville   | company_name: LocatoCo |
      | North Pole | company_name: LocatoCo |
      | Detroit    | company_name: LocatoCo |
      | Emptyville | company_name: LocatoCo |
    And the following users exist:
      | location         | demo                   |
      | name: North Pole | company_name: LocatoCo |
      | name: Detroit    | company_name: LocatoCo |
      | name: Detroit    | company_name: LocatoCo |
      | name: North Pole | company_name: LocatoCo |
      | name: Whoville   | company_name: LocatoCo |
      | name: North Pole | company_name: LocatoCo |
    When I sign in via the login page as an admin
    And I go to the admin "LocatoCo" user-by-location page
    Then I should see "Detroit 2 Emptyville 0 North Pole 3 Whoville 1"
