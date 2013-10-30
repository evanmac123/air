Feature: User sees only friends in current demo

  Background:
    Given the following users exist:
      | name     | demo             |
      | Dan      | name: Thoughtbot |
      | Chad     | name: Thoughtbot |
      | Nick     | name: Thoughtbot |
      | Jon      | name: Thoughtbot |
      | Mike     | name: Thoughtbot |
      | Vlad     | name: H Engage   |
      | Phil     | name: H Engage   |
      | Kristina | name: H Engage   |
      | Kim      | name: H Engage   |
      
      
    And "Dan" is friends with "Chad"
    And "Dan" requests to be friends with "Jon"
    And "Mike" requests to be friends with "Dan"
    When an admin moves "Dan" to the demo "H Engage"
    And "Dan" is friends with "Vlad"
    And "Dan" is friends with "Phil"
    And "Dan" requests to be friends with "Kristina"
    When an admin moves "Dan" to the demo "Thoughtbot"
    
    


    And "Dan" has privacy level "everybody"
    And "Chad" has the password "foobar"
    And "Phil" has the password "foobar"

  Scenario: User sees only accepted friends in current demo, with correct counts
    When I sign in via the login page as "Chad/foobar"
    And I go to the profile page for "Dan"
    Then I should see "Chad" in the friends list
    And I should not see "Vlad" in the friends list
    And I should not see "Phil" in the friends list
    Then I should see 1 person being followed
    And I should see "Dan is now connected with Chad"
    And I should not see "Dan is now connected  with Vlad"
    And I should not see "Dan is now connected  with Phil"
  
  Scenario: User sees correct follower and following count after moving demos
    When an admin moves "Dan" to the demo "H Engage"
    And I sign in via the login page as "Phil/foobar"
    And I go to the profile page for "Dan"
    Then I should not see "Chad" in the friends list
    And I should see "Vlad" in the friends list
    And I should see "Phil" in the friends list
    Then I should see 2 people being followed
    And I should not see "Dan is now connected  with Chad"
    And I should see "Dan is now connected with Vlad"
    And I should see "Dan is now connected  with Phil"
