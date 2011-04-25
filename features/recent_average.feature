Feature: Moving average of points and ranking based on it

  Scenario: Recent average points and ranking bumped appropriately when user acts
    Given the following users exist:
      | name | recent_average_points | recent_average_history_depth | phone_number | demo                  |
      | Dan  | 20                    | 0                            | +14155551212 | company_name: FooCorp |
      | Bob  | 18                    | 3                            | +16178675309 | company_name: FooCorp |
    And the following rule exists:
      | value      | points | demo                  |
      | made toast | 7      | company_name: FooCorp |
    And "Bob" has the password "foo"
    When "+16178675309" sends SMS "made toast"
    And I sign in via the login page as "Bob/foo"
    And I go to the acts page
    Then I should see "21" recent average points
    And I should see "1st out of 2" recent average ranking
