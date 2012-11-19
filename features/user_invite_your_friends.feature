Feature: User invites friends

  Background:
    Given the following demo exists:
      | name       | game_referrer_bonus | join_type     |
      | Bratwurst  | 2000                | self-inviting |
      | Gleason    | 2000                | self-inviting |
      | Preloaded  | 2000                | pre-populated |
      | NotStarted | 2000                | self-inviting |

    Given the following users exist:
      | name               | demo            | email                | slug      | sms_slug    | privacy level |
      | Charlie Brainfield | name: Preloaded | 1@loaded.com         | airplane  | airplane    | everybody     |
      | Yo Yo Ma           | name: Preloaded | 2@loaded.com         | naked     | naked       | everybody     |
      | Threefold          | name: Preloaded | 3@loaded.com         | eraser    | eraser      | everybody     |
      | Fourfold           | name: Preloaded | 4@loaded.com         | owl       | owl         | everybody     |
      | Watermelon         | name: Gleason   | 1@biker.com          | jumper    | jumper      | everybody     |
      | Bruce Springsteen  | name: Gleason   | 2@biker.com          | airairair | airairair   | everybody     |
      | Barnaby Watson     | name: Gleason   | 3@biker.com          | mypeeps   | mypeeps     | everybody     |
      | Charlie Moore      | name: Gleason   | 4@biker.com          | livingit  | livingit    | everybody     |
      | Already Playing    | name: Bratwurst | playing@inviting.com | playing   | playing     | everybody     |

    Given the following brand new users exist:
      | name       | demo            | email                       | slug      | sms_slug    | phone_number | privacy level | notification_method |
      | Barnaby    | name: Bratwurst | claimed@inviting.com        | smoke     | smoke       | +15554445555 | everybody     | both                |
      | Alexander  | name: Bratwurst | also_claimed@inviting.com   | soap      | soap        | +15554442222 | everybody     | both                |
      | Outsider   | name: Gleason   | different_game@inviting.com | box       | box         | +15554442211 | everybody     | both                |
      | Shelly     | name: Preloaded | pre@loaded.com              | nada      | nada        | +16662221111 | everybody     | both                |
      | Michelle   | name: Preloaded | playing@loaded.com          | sexy      | sexy        | +16662221199 | everybody     | both                |
      | Yoko       | name: NotStarted| not@started.com             | abb       | abb         | +13384848484 | everybody     | both                |


  @javascript
  Scenario: Status messages when inviting friends on a pre-populated demo
    Given "Shelly" has the password "foobar"
    Given I sign in via the login page as "Shelly/foobar"    
    Then I should see "Invite your friends"
    When I fill in "Which coworkers do you wish to invite?" with "br"
    Then I should see "3+ letters"
    When I fill in "Which coworkers do you wish to invite?" with "jdidillvididkkemmffii"
    Then I should not see "3+ letters, please"
    And I should see "Hmmm...no match"
    And I should see "Please try again"
    When I fill in "Which coworkers do you wish to invite?" with "bra"
    Then I should see "Click on the person you want to invite:"
    Then I should see "Charlie Brainfield"
    And I should not see "Yo Yo Ma"
    
  @javascript
  Scenario: One click invite of friend on pre-populated demo--friend receives invite and joins game
    Given "Shelly" has the password "foobar"
    Given I sign in via the login page as "Shelly/foobar"    
    Then I should see "Invite your friends"
    When I fill in "Which coworkers do you wish to invite?" with "bra"
    Then I should see "Charlie Brainfield"
    When I press the invite button for "Charlie Brainfield"
    Then I should see "Invitation sent"
    And DJ works off
    Then "1@loaded.com" should receive an email
    When "1@loaded.com" opens the email
    And I click the play now button in the email
    Then I should be on the invitation page for "1@loaded.com"
    When I fill in "Enter your mobile number" with "2088834848"
    And I fill in "Choose a password" with "password"
    And I fill in "Confirm password" with "password"
    And I check "Terms and conditions"
    And I press "Log in"
    And I wait a second
    When I follow "Skip this step"
    Then I should see "Brought to you by"
    Then user with email "1@loaded.com" should show up as referred by "Shelly"
    And DJ works off
    And "+16662221111" should have received SMS "Charlie Brainfield gave you credit for referring them to the game. Many thanks and 2000 bonus points!"
    When "pre@loaded.com" opens the email
    Then I should see "Charlie Brainfield gave you credit for referring them to the game. Many thanks and 2000 bonus points!" in the email body
    And I should see "Shelly got credit for referring Charlie Brainfield to the game"
    And I should see "2000 pts"
   

  @javascript
  Scenario: User should not be able to invite herself
    Given "Yo Yo Ma" has the password "yummies"
    Given I sign in via the login page as "Yo Yo Ma/yummies"    
    Then I should see "Invite your friends"
    When I fill in "Which coworkers do you wish to invite?" with "loaded"
    Then I should see "Charlie Brainfield"
    And I should not see "Yo Yo Ma" within the suggested users
