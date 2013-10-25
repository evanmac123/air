Feature: Directory of other users

  Background:
    Given the following claimed users exist:
      | name           | avatar file name | demo          |
      | Dan            | dan.png          | name: AlphaCo |
      | Sven           |                  | name: AlphaCo |
      | Phil Darnowsky | phil.png         | name: AlphaCo |
      | Phil Aaronson  | vlad.png         | name: AlphaCo |
      | Phil Zymurgy   |                  | name: AlphaCo |
      | Phil Othergame | mort.png         | name: BetaCo  |
    And "Sven" has no avatar
    And "Phil Zymurgy" has no avatar
    And the following friendships exist:
      | user       | friend               | state    |
      | name: Dan  | name: Phil Darnowsky | accepted |
      | name: Dan  | name: Phil Aaronson  | accepted |
    And "Dan" has the password "foobar"
    And I sign in via the login page as "Dan/foobar"
    And I go to the users page
  
  Scenario: Follow controls appear for other users
    Given I fill in "search bar" with "Sven"
    And I press "Find!"
    Then I should see a follow button for "Sven"
    And I should not see an unfollow button for "Sven"
    When I fill in "search bar" with "Phil"
    And I press "Find!"
    Then I should see an unfollow button for "Phil Aaronson"
    And I should not see a follow button for "Phil Aaronson"
    And I should see an unfollow button for "Phil Darnowsky"
    And I should not see a follow button for "Phil Darnowsky"
    And I should not see a follow button for "Phil Othergame"
    And I should not see an unfollow button for "Phil Othergame"

  Scenario: Other users in alphabetical order
    Given I fill in "search bar" with "phil"
    And I press "Find!"
    Then I should see "Phil Aaronson,Phil Darnowsky,Phil Zymurgy" in that order
    
  Scenario: Users are searchable
    Given I fill in "search bar" with "phi"
    And I press "Find!"
    Then I should see "Phil Darnowsky" within a link to the user page for "Phil Darnowsky" in the Other Players list
    And I should see an avatar "phil.png" for "Phil Darnowsky"
    And I should see "Phil Aaronson" within a link to the user page for "Phil Aaronson" in the Other Players list
    And I should see an avatar "vlad.png" for "Phil Aaronson"
    And I should see "Phil Zymurgy" within a link to the user page for "Phil Zymurgy" in the Other Players list
    And I should see the default avatar for "Phil Zymurgy"
    And I should not see "Sven"
    And I should not see "Phil Othergame"
 
  Scenario: Success message
    Given I fill in "search bar" with "Sven"
    And I press "Find!"
    And I press the button next to "Sven"
    Then I should see "OK, you'll be connected with Sven, pending their acceptance."
    When I press the button next to "Sven"
    Then I should see "Connection request canceled"
