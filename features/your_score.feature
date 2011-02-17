Feature: Your score display

  As a player
  In order to know how I'm doing against others and stoke my competitive urges
  I want to see my current score and ranking

  Scenario: Your score displayed on dashboard
    Given the following users exist:
      | name | points | demo                |
      | Lazy | 0      | company_name: Alpha |
      | Tony | 24     | company_name: Alpha |
      | Bleh | 2      | company_name: Alpha |
      | Phil | 634923 | company_name: Alpha |
      | Vlad | 17     | company_name: Alpha |
      | Dan  | 10     | company_name: Alpha |
    And "Tony" has the password "whatnot"
    And I sign in via the login page as "Tony/whatnot"
    When I go to the acts page
    Then I should see "24" in your snapshot table
    And I should see "2nd out of 6" in your snapshot table
