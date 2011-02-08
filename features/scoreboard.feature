Feature: Scoreboard

  Background:
    Given the following users exist:
      | name | points | demo                |
      | Lazy | 0      | company_name: Alpha |
      | Tony | 24     | company_name: Alpha |
      | Bleh | 2      | company_name: Alpha |
      | Phil | 634923 | company_name: Alpha |
      | Vlad | 17     | company_name: Alpha |
      | Dan  | 10     | company_name: Alpha |
      | Who  | 44     | company_name: Enron |
    And "Lazy" has the password "foobar"
    And I sign in via the login page as "Lazy/foobar"

  Scenario: Scoreboard on acts page
    When I go to the acts page
    Then I should see a scoreboard for demo "Alpha"

  Scenario: Scoreboard on home page
    When I go to the home page
    Then I should see a scoreboard for demo "Alpha"
