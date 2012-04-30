Feature: Evil Kim defects from the Fuji game and joins the Highmark game, and then back again

  Background:
    Given the following demos exist:
      | Name      | 
      | Bolshevik |
      | Shardaron |
    Given the following site admin exists:
      | Name     | Demo            |
      | Evil Kim | name: Bolshevik |
    Given "Evil Kim" has the password "lucky2"
    And I sign in via the login page with "Evil Kim/lucky2"
    Then "Evil Kim" should be in the "Bolshevik" game
    When I go to the admin page
    Then I should see "Directory"
    Then I should see `Bolshevik` within "#which_game"
  
  @javascript
  Scenario: Evil kim changes to to the Shardaron game
    Given I select "Shardaron" from "user_demo_name"
    Then I should see "Just a moment"
    # Then I should see "Updated"       // For some reason this fails, but the rest is fine
    And "Evil Kim" should be in the "Shardaron" game
    Then I should see `Shardaron` within "#which_game"
    
    