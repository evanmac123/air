Feature: Avatars shown and updatable

  Background:
    Given the following users exist:
      | name | demo                        |
      | Dan  | company_name: The Internets |
      | Gax  | company_name: The Internets |
    And "Dan" has the password "foo"
    And I sign in via the login page as "Dan/foo"

  Scenario: User can set their avatar
    When I go to the profile page for "Dan"
    And I attach the avatar "alistair.jpg"
    And I press "Set Picture"
    Then I should be on the profile page for "Dan"
    Then I should see an avatar "alistair.jpg" for "Dan"

  Scenario: User can change a set avatar
    When I go to the profile page for "Dan"
    And I attach the avatar "alistair.jpg"
    And I press "Set Picture"
    And I attach the avatar "maggie.jpg"
    And I press "Set Picture"
    Then I should be on the profile page for "Dan"
    And I should see an avatar "maggie.jpg" for "Dan"

  Scenario: User gets sensible error if they try to set avatar without choosing a file
    When I go to the profile page for "Dan"
    And I press "Set Picture"
    Then I should be on the profile page for "Dan"
    And I should see the default avatar for "Dan"
    And I should see "Please choose a file to use for your avatar."

  Scenario: User can delete their avatar
    When I go to the profile page for "Dan"
    And I attach the avatar "alistair.jpg"
    And I press "Set Picture"
    When I press "Clear Picture"
    Then I should be on the profile page for "Dan"
    And I should see the default avatar for "Dan"
