Feature: Skinnable pages

  Background:
    Given the following demo exists:
      | company name |
      | BlargCo      |
    And the following users exist:
      | name | points | phone number | won at                  | demo                  |
      | Joe  | 10     | +14155551212 | 1999-05-01 12:00:00 UTC | company_name: BlargCo |
      | Bob  | 40     | +14155551213 | 1999-05-01 12:00:00 UTC | company_name: BlargCo |
    And the following acts exist:
      | text       | inherent points | user       | demo                  |
      | Ate cheese | 15              | name: Joe  | company_name: BlargCo |
    And the following friendships exist:
      | user      | friend    |
      | name: Bob | name: Joe |
    And "Joe" has password "foo"
    And I sign in via the login page with "Joe/foo"

  Scenario: Pages have skin applied
    Given I need to write this

  Scenario: Pages have default appearance
    When I go to the activity page
    Then the logo graphic should have src "new_activity/img_logo.png"
    And the play now button graphic should have src "new_activity/btn_playnow.png"
    And the see more button graphics should have src "new_activity/btn_seemore.png"
    And the victory graphics should have src "new_activity/img_bluestar_18.png"
    And the header background should have no element graphic
    And the nav links should have no element color
    And the active nav link should have no element color
    And profile links should have no element color
    And activity feed points should have no element color
    And scoreboard points should have no element color
    And column headers should have no element color

    When I go to the profile page for "Joe"
    Then the logo graphic should have src "new_activity/img_logo.png"
    And the play now button graphic should have src "new_activity/btn_playnow.png"
    And the see more button graphics should have src "new_activity/btn_seemore.png"
    And the header background should have no element graphic
    And the nav links should have no element color
    And the active nav link should have no element color
    And profile links should have no element color
    And activity feed points should have no element color
    And save button graphics should have src "new_activity/btn_save.png"
    #And clear picture button graphics should have the right src

    When I go to the profile page for "Bob"
    Then the logo graphic should have src "new_activity/img_logo.png"
    And the play now button graphic should have src "new_activity/btn_playnow.png"
    And the see more button graphics should have src "new_activity/btn_seemore.png"
    And the header background should have no element graphic
    And the nav links should have no element color
    And the active nav link should have no element color
    And profile links should have no element color
    And activity feed points should have no element color
    And fan button graphics should have src "new_activity/btn_beafan.png"
    And I need to finish writing this

    When I press the fan button
    Then de-fan button graphics should have src "new_activity/btn_defan.png"
