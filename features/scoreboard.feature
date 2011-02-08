Feature: Scoreboard

  Scenario: Scoreboard on acts page
    Given the following users exist:
      | name | points | demo                |
      | Lazy | 0      | company_name: Alpha |
      | Bleh | 2      | company_name: Alpha |
      | Dan  | 10     | company_name: Alpha |
      | Vlad | 17     | company_name: Alpha |
      | Tony | 24     | company_name: Alpha |
      | Phil | 634923 | company_name: Alpha |
    And "Lazy" has the password "foobar"
    When I sign in via the login page as "Lazy/foobar"
    And I go to the acts page
    Then I should see a scoreboard

  Scenario: Scoreboard on home page
    Given the following users exist:
      | name | points | demo                |
      | Lazy | 0      | company_name: Alpha |
      | Bleh | 2      | company_name: Alpha |
      | Dan  | 10     | company_name: Alpha |
      | Vlad | 17     | company_name: Alpha |
      | Tony | 24     | company_name: Alpha |
      | Phil | 634923 | company_name: Alpha |
    When I sign in via the login page
    And I go to the home page
    Then I should see a scoreboard
