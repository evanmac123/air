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
      | demo          | logo_url       | 
      | name: BlargCo | blarg_logo.gif | 
    When I go to the activity page
    Then the logo should have src "blarg_logo.gif"

    When I go to the profile page for "Joe"
    Then the logo should have src "blarg_logo.gif"

    When I go to the profile page for "Bob"
    Then the logo should have src "blarg_logo.gif"

  Scenario: Pages have default appearance
    When I go to the activity page
    Then the logo should have src "logo.png"

    When I go to the profile page for "Joe"
    Then the logo should have src "logo.png"

    When I go to the profile page for "Bob"
    Then the logo should have src "logo.png"
