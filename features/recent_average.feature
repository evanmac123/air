Feature: Moving average of points and ranking based on it

  Scenario: Recent average points and ranking bumped appropriately when user acts
    Given the following users exist:
      | name | recent_average_points | recent_average_history_depth | phone_number | demo                  |
      | Dan  | 20                    | 0                            | +14155551212 | company_name: FooCorp |
      | Bob  | 18                    | 3                            | +16178675309 | company_name: FooCorp |
    And the following rule exists:
      | reply | points | demo                  | demo                  |
      | toast | 7      | company_name: FooCorp | company_name: FooCorp |
    And the following rule value exists:
      | value      | rule         |
      | made toast | reply: toast |
    And "Bob" has the password "foo"
    When "+16178675309" sends SMS "made toast"
    And I sign in via the login page as "Bob/foo"
    And I go to the acts page
    Then I should see "21" recent average points
    And I should see "1 of 2" recent average ranking
