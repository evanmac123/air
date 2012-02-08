Feature: Directory of other users

  Background:
    Given the following claimed users exist:
      | name | avatar file name | demo          |
      | Dan  | dan.png          | name: AlphaCo |
      | Sven |                  | name: AlphaCo |
      | Phil | phil.png         | name: AlphaCo |
      | Vlad | vlad.png         | name: AlphaCo |
      | Mort | mort.png         | name: BetaCo  |
    And "Sven" has no avatar
    And the following friendships exist:
      | user       | friend     |
      | name: Dan  | name: Phil |
      | name: Dan  | name: Vlad |
    And "Dan" has the password "foobar"
    And I sign in via the login page as "Dan/foobar"
    And I go to the users page

  Scenario: Names appear for other users
    Then I should see "Phil" within a link to the user page for "Phil"
    And I should see "Vlad" within a link to the user page for "Vlad"
    And I should see "Sven" within a link to the user page for "Sven"
    And I should not see a link to the user page for "Mort"
  
  Scenario: Avatars appear for other users
    Then I should see an avatar "phil.png" for "Phil"
    And I should see an avatar "vlad.png" for "Vlad"
    And I should see the default avatar for "Sven"
    And I should not see an avatar "mort.png" for "Mort"
  
  Scenario: Follow controls appear for other users
    Then I should see a follow button for "Sven"
    And I should not see an unfollow button for "Sven"
    And I should see an unfollow button for "Vlad"
    And I should not see a follow button for "Vlad"
    And I should see an unfollow button for "Phil"
    And I should not see a follow button for "Phil"
    And I should not see a follow button for "Mort"
    And I should not see an unfollow button for "Mort"

  Scenario: Other users in alphabetical order
    Then I should see "Phil,Sven,Vlad" in that order
