Feature: User sees correct values in master bar

  Scenario Outline:
    Given the following demo exists:
      | company name | victory threshold |
      | BarCo        | 100               |
    And the following levels exist:
      | threshold | demo                |
      | 10        | company_name: BarCo |
      | 20        | company_name: BarCo |
      | 30        | company_name: BarCo |
      | 50        | company_name: BarCo |
      | 80        | company_name: BarCo |
      | 130       | company_name: BarCo |
    And the following users exist:
      | name | points | demo                |
      | Al   | 6      | company_name: BarCo |
      | Bob  | 16     | company_name: BarCo |
      | Cal  | 23     | company_name: BarCo |
      | Dave | 39     | company_name: BarCo |
      | Ed   | 62     | company_name: BarCo |
      | Fred | 87     | company_name: BarCo |
      | Ger  | 120    | company_name: BarCo |
      | Hal  | 140    | company_name: BarCo |
      | Ike  | 0      | company_name: BarCo |
      | Jay  | 30     | company_name: BarCo |
      | Kal  | 100    | company_name: BarCo |
    And "<name>" has the password "foobar"
    And I sign in via the login page as "<name>/foobar"

    Then the master bar should show <percent>% complete
    And the master bar should show <points> points

    Scenarios:
      | name | points | percent |      
      | Al   | 6      | 60.0    |
      | Bob  | 6      | 60.0    |
      | Cal  | 3      | 30.0    |
      | Dave | 9      | 45.0    |
      | Ed   | 12     | 40.0    |
      | Fred | 7      | 35.0    |
      | Ger  | 20     | 66.67   |
      | Hal  | 10     | 100.0   |
      | Ike  | 0      | 0.0     |
      | Jay  | 0      | 0.0     |
      | Kal  | 0      | 0.0     |

