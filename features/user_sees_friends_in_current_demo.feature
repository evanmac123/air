Feature: User sees only friends in current demo

  Background:
    Given the following users exist:
      | name     | demo                     |
      | Dan      | name: Thoughtbot |
      | Chad     | name: Thoughtbot |
      | Nick     | name: Thoughtbot |
      | Jon      | name: Thoughtbot |
      | Mike     | name: Thoughtbot |
      | Vlad     | name: H Engage   |
      | Phil     | name: H Engage   |
      | Kristina | name: H Engage   |
      | Kim      | name: H Engage   |
    And the following accepted friendships exist:
      | user       | friend     |
      | name: Dan  | name: Chad |
      | name: Dan  | name: Vlad |
      | name: Dan  | name: Phil |
      | name: Nick | name: Dan  |
      | name: Vlad | name: Dan  |
      | name: Phil | name: Dan  |
    And the following friendships exist:
      | user           | friend     |
      | name: Jon      | name: Dan  |
      | name: Kristina | name: Dan  |
      | name: Dan      | name: Mike |
      | name: Dan      | name: Kim  |

  Scenario: User sees only accepted friends in current demo, with correct counts
    When I need to hook this up
    When I sign in via the login page
    And I go to the profile page for "Dan"
    Then I should see "fan of 1 person"
    And I should see "has 1 fan"

  Scenario: User sees correct follower and following count after moving demos
    When I need to hook this up
    When an admin moves "Dan" to the demo "H Engage"
    And I sign in via the login page
    And I go to the profile page for "Dan"
    Then I should see "fan of 2 people"
    And I should see "has 2 fans"
