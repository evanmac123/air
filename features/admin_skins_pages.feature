Feature: Skinnable pages

  Background:
    Given the following demo exists:
      | name         | custom_logo_url |
      | BlargCo      | blarg_logo.gif  |
      | DefaultCo    |                 |
    And the following claimed users exist:
      | name | points | phone number | won at                  | demo            |
      | Joe  | 10     | +14155551212 | 1999-05-01 12:00:00 UTC | name: BlargCo   |
      | Bob  | 40     | +14155551213 | 1999-05-01 12:00:00 UTC | name: BlargCo   |
      | Fred | 7      | +14155551214 | 1999-05-01 12:00:00 UTC | name: DefaultCo |
      | Bill | 23202  | +14155551215 | 1999-05-01 12:00:00 UTC | name: DefaultCo |

  Scenario: Pages have skin applied
    When "Joe" has password "foobar"
    And I sign in via the login page with "Joe/foobar"

    When I go to the activity page
    Then the logo should have src "blarg_logo.gif"

    When I go to the profile page for "Joe"
    Then the logo should have src "blarg_logo.gif"

    When I go to the profile page for "Bob"
    Then the logo should have src "blarg_logo.gif"

  Scenario: Pages have default appearance
    when "Fred" has the password "foboar"
    And I sign in via the login page with "Joe/foobar"

    When I go to the activity page
    Then the logo should have src "logo.png"

    When I go to the profile page for "Fred"
    Then the logo should have src "logo.png"

    When I go to the profile page for "Bill"
    Then the logo should have src "logo.png"
