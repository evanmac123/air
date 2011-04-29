Feature: Your score display

  As a player
  In order to know how I'm doing against others and stoke my competitive urges
  I want to see my current score and ranking

  Scenario: Your score displayed on dashboard
    Given the following users exist:
      | name | points | recent_average_points | demo                | phone_number |
      | Lazy | 0      | 14                    | company_name: Alpha | +19435034923 |
      | Tony | 24     | 41                    | company_name: Alpha | +15893948923 |
      | Bleh | 2      | 19                    | company_name: Alpha | +15892384923 |
      | Phil | 634923 | 46                    | company_name: Alpha | +19895834234 |
      | Vlad | 17     | 25                    | company_name: Alpha | +19839582934 |
      | Dan  | 10     | 43                    | company_name: Alpha | +15893842334 |
      | Bob  | 0      | 0                     | company_name: Alpha |              |
    And "Tony" has the password "whatnot"
    And I sign in via the login page as "Tony/whatnot"
    When I go to the acts page
    Then I should see "24" alltime points
    And I should see "2 of 6" alltime ranking
    And I should see "41" recent average points
    And I should see "3 of 6" recent average ranking
