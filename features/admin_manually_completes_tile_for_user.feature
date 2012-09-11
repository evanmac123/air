Feature: Admin manually completes a tile for a user

  @javascript
  Scenario: Admin manually completes a tile for a user
    Given the following demo exists:
      | name |
      | TileCo       |
    And the following claimed users exist:
      | name | phone number | demo                 |
      | Joe  | +14155551212 | name: TileCo |
    And "Joe" has the password "foobar"
    And the following tiles exist:
      | name   | demo                 |
      | Tile 1 | name: TileCo |
      | Tile 2 | name: TileCo |
      | Tile 3 | name: TileCo |
      | Tile 4 | name: TileCo |
    And the tile "Tile 2" has prerequisite "Tile 1"
    And the tile "Tile 4" has prerequisite "Tile 3"
    And DJ works off
    And I sign in via the login page with "Joe/foobar"

    Then I should see "Tile 1"
    And I should see "Tile 3"
    But I should not see "Tile 2"
    And I should not see "Tile 4"

    When I sign in via the login page as an admin
    And I go to the admin "TileCo" demo page
    And I follow "J"
    And I follow "Joe"
    And I press "Complete Tile 1 for Joe"
    Then I should see "Tile 1 manually completed for Joe"
    And I should not see an input with value "Complete Tile 1 for Joe"
    And I should not see an input with value "Complete Tile 4 for Joe"
    But I should see an input with value "Complete Tile 2 for Joe"
    And I should see an input with value "Complete Tile 3 for Joe"

    When I sign in via the login page with "Joe/foobar"
    Then I should see "Tile 2"
    And I should see "Tile 3"
    But I should not see "Tile 1"
    And I should not see "Tile 4"

    When DJ works off after a little while
    And "+14155551212" should have received an SMS "Congratulations! You've completed a daily dose."
