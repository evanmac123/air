Feature: User sees only friends in current demo

  Background:
    Given the following users exist:
      | name     | demo                     |
      | Dan      | company_name: Thoughtbot |
      | Chad     | company_name: Thoughtbot |
      | Nick     | company_name: Thoughtbot |
      | Jon      | company_name: Thoughtbot |
      | Mike     | company_name: Thoughtbot |
      | Vlad     | company_name: H Engage   |
      | Phil     | company_name: H Engage   |
      | Kristina | company_name: H Engage   |
      | Kim      | company_name: H Engage   |
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
    When I sign in via the login page
    And I go to the profile page for "Dan"
    Then I should see "fan of 1 person"
    And I should see "has 1 fan"

  Scenario: User sees correct follower and following count after moving demos
    When an admin moves "Dan" to the demo "H Engage"
    And I sign in via the login page
    And I go to the profile page for "Dan"
    Then I should see "fan of 2 people"
    And I should see "has 2 fans"
