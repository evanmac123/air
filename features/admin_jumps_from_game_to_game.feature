Feature: Evil Kim defects from the Fuji game and joins the Highmark game, and then back again

  @javascript
  Scenario: Evil kim changes to to the Shardaron game
    Given the following demos exist:
      | Name      |
      | Bolshevik |
      | Shardaron |
    And the following site admin exists:
      | Name     | Demo            |
      | Evil Kim | name: Bolshevik |
    And "Evil Kim" has the password "lucky2"
    When I sign in via the login page with "Evil Kim/lucky2"
    Then "Evil Kim" should be in the "Bolshevik" game
    When I go to the admin page
    Then "user_demo_name" should have "Bolshevik" selected
    When I select "Shardaron" from "user_demo_name"
    Then I should see "Just a moment"
    And "Evil Kim" should be in the "Shardaron" game

    
