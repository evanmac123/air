Feature: Client Admin has his first tile completed and gets congratulation letter about it

  Scenario: Client admin creates first tiles and gets feedback
    Given the following user exists:
      | name | email           | demo        | is_client_admin |
      | Joe  | joe@example.com | name: FooCo | true            |
    And "Joe" has the password "foobar"
    And the following tiles exist:
      | headline              | demo        | status |
      | Make toast            | name: FooCo | active |
      | Make PBJ              | name: FooCo | active |
      | Butter toast          | name: FooCo | active |
    And the tile "Make toast" has creator "Joe"
    And the tile "Make PBJ" has creator "Joe"
    And the tile "Butter toast" has creator "Joe"
    And the following user exists:
      | name   | email             | demo        |
      | Misha  | misha@example.com | name: FooCo |
    And "Misha" has the password "foobar"
    When I sign in via the login page with "Misha/foobar"
    Then I should see the "Make toast" tile
    And I should see the "Make PBJ" tile
    And I should see the "Butter toast" tile
    When "Misha" satisfies tile "Make toast"
    And I sign in via the login page with "Joe/foobar"
    Then "joe@example.com" should receive 1 email
    When "joe@example.com" opens the email
    And I click the check activity button in the email
    Then I should be on the manage tiles page
    When "Misha" satisfies tile "Make PBJ"
    Then "joe@example.com" should receive 0 email

