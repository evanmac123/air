Feature: User sets their privacy level

  Background:
    Given the following demo exists:
      | company name |
      | Privata      |
    And the following users exist:
      | name      | demo                  |
      | Bob       | company_name: Privata |
      | AlmostFan | company_name: Privata |
      | TrueFan   | company_name: Privata |
    And "Bob" has the password "foobar"
    And "AlmostFan" has the password "foobar"
    And "TrueFan" has the password "foobar"
    And I sign in via the login page as "Bob/foobar"

  Scenario: User with (default) privacy level of "everybody" shows their acts to everybody in demo
    Given the following user exists:
      | name | demo                  |
      | TMI  | company_name: Privata |
    And the following user exists:
      | name  | privacy_level  | demo                  |
      | WTMI  | everybody      | company_name: Privata |
    And the following acts exist:
      | text        | user       |  
      | ate kitten  | name: TMI  |
      | ate puppy   | name: WTMI |
    And I go to the activity page
    Then I should see "TMI ate kitten less than a minute ago"
    And I should see "WTMI ate puppy less than a minute ago"

  Scenario: User with privacy level of "connected" shows their acts to fans only
    Given the following user exists:
      | name  | privacy_level | demo                  |
      | Fanny | connected     | company_name: Privata |
    And the following act exists:
      | text       | user        |
      | ate kitten | name: Fanny |
    And the following friendships exist:
      | user            | friend      | state    |
      | name: AlmostFan | name: Fanny | pending  |
      | name: TrueFan   | name: Fanny | accepted |

    When I sign in via the login page with "Bob/foobar"
    Then I should be on the activity page
    But I should not see "Fanny ate kitten"

    When I sign in via the login page with "AlmostFan/foobar"
    Then I should be on the activity page
    But I should not see "Fanny ate kitten"

    When I sign in via the login page with "TrueFan/foobar"
    Then I should be on the activity page
    And I should see "Fanny ate kitten"

  Scenario: User with privacy level of "nobody" show their acts to nobody    
    Given the following user exists:
      | name    | privacy_level | demo                  |
      | Private | nobody        | company_name: Privata |
    And the following act exists:
      | text       | user         |
      | ate kitten | name: Private |
    And the following friendships exist:
      | user            | friend        | state    |
      | name: AlmostFan | name: Private | pending  |
      | name: TrueFan   | name: Private | accepted |

    When I sign in via the login page with "Bob/foobar"
    Then I should be on the activity page
    But I should not see "Private ate kitten"

    When I sign in via the login page with "AlmostFan/foobar"
    Then I should be on the activity page
    But I should not see "Private ate kitten"

    When I sign in via the login page with "TrueFan/foobar"
    Then I should be on the activity page
    But I should not see "Private ate kitten"

  Scenario Outline: User can always see their own acts
    Given the following act exists:
      | text       | user      |
      | ate kitten | name: Bob |
    When I go to the activity page
    Then I should see "Bob ate kitten"

    When I go to the settings page
    And I select "<level>" from "Let these people see my actions:"
    And I press the button to save privacy settings
    And I go to the activity page
    Then I should see "Bob ate kitten"

    Scenarios:
      | level                   |
      | Everybody               |
      | Followers I've accepted |
      | Nobody                  |

  Scenario: User can set their privacy level in the settings page
    When I go to the settings page
    Then "Let these people see my actions:" should have "Everybody" selected

    When I select "Followers I've accepted" from "Let these people see my actions:"
    And I press the button to save privacy settings
    Then I should see "OK, your settings were updated."
    And "Let these people see my actions:" should have "Followers I've accepted" selected

    When I select "Nobody" from "Let these people see my actions:"
    And I press the button to save privacy settings
    Then I should see "OK, your settings were updated."
    And "Let these people see my actions:" should have "Nobody" selected
