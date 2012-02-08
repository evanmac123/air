Feature: Skinnable pages

  Background:
    Given the following demo exists:
      | name |
      | BlargCo      |
    And the following claimed users exist:
      | name | points | phone number | won at                  | demo                  |
      | Joe  | 10     | +14155551212 | 1999-05-01 12:00:00 UTC | name: BlargCo |
      | Bob  | 40     | +14155551213 | 1999-05-01 12:00:00 UTC | name: BlargCo |
      | Fred | 7      | +14155551214 | 1999-05-01 12:00:00 UTC | name: BlargCo |
    And the following acts exist:
      | text       | inherent points | user       | 
      | Ate cheese | 15              | name: Joe  | 
    And the following accepted friendships exist:
      | user       | friend    |
      | name: Joe  | name: Bob |
      | name: Fred | name: Joe |
    And "Joe" has password "foobar"
    And I sign in via the login page with "Joe/foobar"

  Scenario: Pages have skin applied
    Given the following skin exists:
      | demo                  | header_background_url | nav_link_color | active_nav_link_color | logo_url | play_now_button_url | save_button_url | see_more_button_url | fan_button_url | defan_button_url | clear_button_url | profile_link_color | column_header_background_color | victory_graphic_url | points_color |
      | name: BlargCo | header.gif            | 000000         | 111111                | logo.gif | playnow.gif         | save.gif        | seemore.gif          | fan.gif       | defan.gif        | clear.gif        | 222222             | 333333                         | victory.gif         | 444444       |
    When I go to the activity page
    Then the logo should have src "logo.gif"
    # And the victory graphics should have src "victory.gif"

    When I go to the profile page for "Joe"
    Then the logo should have src "logo.gif"

    When I go to the profile page for "Bob"
    Then the logo should have src "logo.gif"

    When I go to the connections page    
    Then the logo should have src "logo.gif"

  Scenario: Partial skinning does what you would expect
    Given the following skin exists:
      | demo                  | active_nav_link_color | logo_url |
      | name: BlargCo | AAAAAA                | logo.gif |
    When I go to the activity page
    Then the logo should have src "logo.gif"

  Scenario: Pages have default appearance
    When I go to the activity page
    Then the logo should have src "logo.png"
    # And the victory graphics should have src "new_activity/img_bluestar_18.png"

    When I go to the profile page for "Joe"
    Then the logo should have src "logo.png"

    When I go to the profile page for "Bob"
    Then the logo should have src "logo.png"

    # When I go to the profile page for "Fred"
    # Then the fan button should have src "new_activity/btn_beafan.png"

    When I go to the connections page    
    Then the logo should have src "logo.png"
    Then the de-fan button should have src "new_activity/btn_defan.png"
    When I press the de-fan button
    Then I should be on the connections page
    And the fan button should have src "new_activity/btn_beafan.png"
