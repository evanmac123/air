Feature: User sets their privacy level

  Background:
    Given the following demo exists:
      | name    |
      | Privata |
    And the following users exist:
      | name      | demo          |
      | Bob       | name: Privata |
      | AlmostFan | name: Privata |
      | TrueFan   | name: Privata |
    And "Bob" has the password "foobar"
    And "AlmostFan" has the password "foobar"
    And "TrueFan" has the password "foobar"
    And I sign in via the login page as "Bob/foobar"

#   Scenario: User with privacy level of "everybody" shows their acts to everybody in demo
    # Given the following user exists:
      # | name  | privacy_level  | demo          |
      # | WTMI  | everybody      | name: Privata |
    # And the following acts exist:
      # | text        | user       |  
      # | ate puppy   | name: WTMI |
    # And I go to the activity page
    # Then I should see "WTMI ate puppy less than a minute ago"


#   Scenario: User with privacy level of "nobody" show their acts to nobody    
    # Given the following user exists:
      # | name    | privacy_level | demo                  |
      # | Private | nobody        | name: Privata |
    # And the following act exists:
      # | text       | user         |
      # | ate kitten | name: Private |
    # And the following friendships exist:
      # | user            | friend        | state    |
      # | name: AlmostFan | name: Private | pending  |
      # | name: TrueFan   | name: Private | accepted |

    # When I sign in via the login page with "Bob/foobar"
    # Then I should be on the activity page with HTML forced
    # But I should not see "Private ate kitten"

    # When I sign in via the login page with "AlmostFan/foobar"
    # Then I should be on the activity page with HTML forced
    # But I should not see "Private ate kitten"

    # When I sign in via the login page with "TrueFan/foobar"
    # Then I should be on the activity page with HTML forced
    # But I should not see "Private ate kitten"

#   Scenario Outline: User can always see their own acts
    # Given the following act exists:
      # | text       | user      |
      # | ate kitten | name: Bob |
    # When I go to the activity page
    # Then I should see "Bob ate kitten"

    # When I go to the settings page
    # And I select "<level>" from "Let these people see my actions:"
    # And I press the button to save privacy settings
    # And I go to the activity page
    # Then I should see "Bob ate kitten"

    # Scenarios:
      # | level                     |
      # | Everybody                 |
      # | Connections I've accepted |

  Scenario: User can set their privacy level in the settings page
    When I go to the settings page
    Then "Let these people see my actions:" should have "Connections I've accepted" selected

    When I select "Everybody" from "Let these people see my actions:"
    And I press the button to save privacy settings
    Then I should see "OK, your settings were updated."
    And "Let these people see my actions:" should have "Everybody" selected

  Scenario: User can change their privacy level
    Given the following user exists:
      | name  | privacy_level  | demo          |
      | WTMI  | everybody      | name: Privata |
    And the following friendship exists:
      | user          | friend     | state    |
      | name: TrueFan | name: WTMI | accepted |
    And "WTMI" has the password "foobar"
    And the following acts exist:
      | text        | user       |  
      | ate puppy   | name: WTMI |
    And I go to the activity page

    When I sign in via the login page as "Bob/foobar"
    Then I should see "WTMI ate puppy less than a minute ago"
    When I sign in via the login page as "TrueFan/foobar"
    Then I should see "WTMI ate puppy less than a minute ago"

    When "WTMI/foobar" changes their privacy level to "Connections I've accepted"
    And I sign in via the login page as "Bob/foobar"
    Then I should not see "WTMI ate puppy less than a minute ago"
    When I sign in via the login page as "TrueFan/foobar"
    Then I should see "WTMI ate puppy less than a minute ago"

    When "WTMI/foobar" changes their privacy level to "Everybody"
    And I sign in via the login page as "Bob/foobar"
    Then I should see "WTMI ate puppy less than a minute ago"
    When I sign in via the login page as "TrueFan/foobar"
    Then I should see "WTMI ate puppy less than a minute ago"
