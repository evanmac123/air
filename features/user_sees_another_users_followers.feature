Feature: Directory of other users

  Background:
    Given the following claimed users exist:
      | name | avatar file name | demo          | points |
      | Dan  | dan.png          | name: AlphaCo | 27     |
      | Sven |                  | name: AlphaCo | 30     |
      | Phil | phil.png         | name: AlphaCo | 19     |
      | Vlad | vlad.png         | name: AlphaCo | 0      | 
      | Mort | mort.png         | name: BetaCo  | 237    |
    And "Sven" has no avatar
    And the following accepted friendships exist:
      | user       | friend     | 
      | name: Dan  | name: Phil | 
      | name: Dan  | name: Vlad | 
      | name: Sven | name: Dan  | 
    And the following levels exist:
      | name      | threshold   | demo          |
      | GoGettem  | 50          | name: AlphaCo |
    And "Dan" has the password "foobar"
    And I sign in via the login page as "Dan/foobar"
    And I go to the user page for "Dan"

  Scenario: Names appear for other users
    Then I should see "Phil" within a link to the user page for "Phil"
    And I should see "Vlad" within a link to the user page for "Vlad"
    And I should see "Sven" within a link to the user page for "Sven"
    And I should not see a link to the user page for "Mort"
  
  Scenario: No follow button for yourself
    Then I should not see a follow button for "Dan"