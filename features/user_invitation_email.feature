Feature: User invites friends, and invitation email says what it should

  Background:
    Given the following demo exists:
      | name       | game_referrer_bonus | join_type     | sponsor        |
      | Preloaded  | 2000                | pre-populated | Rocket Science |

    Given the following users exist:
      | name       | demo            | email              |
      | Jinx       | name: Preloaded | jinx@loaded.com       |

    Given the following claimed users exist:
      | name       | demo            | email              |
      | Concord    | name: Preloaded | claimed@loaded.com |
      

  @javascript
  Scenario: One click invite of friend on pre-populated demo--friend receives invite and joins game
    Given "Concord" has the password "raspberry"
    Given I sign in via the login page as "Concord/raspberry"    
    Then I should see "Invite your friends"
    When I fill in "Which coworkers do you wish to invite?" with "jin"
    Then I should see "Jinx"
    When I press the invite button for "Jinx"
    Then I should see "Invitation sent"
    And DJ works off
    Then "jinx@loaded.com" has received an invitation
    When "jinx@loaded.com" opens the email
    Then I should see "Concord has invited you to play" in the email body
    
    And I click the play now button in the email
    Then I should be on the invitation page for "jinx@loaded.com"
    And I should see "Concord"
    When "jinx@loaded.com" opens the email    
    Then I should see "Concord has invited you to play" in the email body
    And I should see "Preloaded at Rocket Science" in the email body
  

    When "jinx@loaded.com" opens the email
    When I click the view in browser link in the email
    Then I should not see "View it in your browser"
    And I should not see "Kermit"
    And I should see "Concord has invited you to play Preloaded at Rocket Science"
    And I follow "play_now_large"
    Then I should be on the invitation page for "jinx@loaded.com"
    And I should see "Concord"
    
    
