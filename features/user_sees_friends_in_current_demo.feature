Feature: User sees only friends in current demo



I recommend disabling cross viewing. (That is why I have not updated this test to pass under the old paradigm)
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
    And "Dan" has privacy level "everybody"
  @wip
  Scenario: User sees only accepted friends in current demo, with correct counts
  
    Wait just a cotton pickin minute! Why are we allowing players in 
    Highmark view players in Fujifilm at all? That sounds like serious
    no no juju.
    
    When I sign in via the login page
    And I go to the profile page for "Dan"
    Then I should see 1 person being followed
    And I should see 1 follower
  @wip
  Scenario: User sees correct follower and following count after moving demos
    When an admin moves "Dan" to the demo "H Engage"
    And I sign in via the login page
    And I go to the profile page for "Dan"
    Then I should see 2 people being followed
    And I should see 2 followers
