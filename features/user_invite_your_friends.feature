Feature: User gives credit to game referer via autocomplete field

  Background:
    Given the following demo exists:
      | name | game_referrer_bonus      |
      | Bratwurst    | 2000             |
      | Gleason      | 2000             |
      | Preloaded    | 2000             |
      | NotStarted   | 2000             |
    Given the following self inviting domain exists:
      | domain       | demo             |
      | inviting.com | name: Bratwurst  |
      | biker.com    | name: Gleason    |
      | started.com  | name: NotStarted |

    Given the following users exist:
      | name               | demo            | email                | slug      | sms_slug    |
      | Charlie Brainfield | name: Preloaded | 1@loaded.com         | airplane  | airplane    |
      | Yo Yo Ma           | name: Preloaded | 2@loaded.com         | naked     | naked       |
      | Threefold          | name: Preloaded | 3@loaded.com         | eraser    | eraser      |
      | Fourfold           | name: Preloaded | 4@loaded.com         | owl       | owl         |
      | Fivefold           | name: Preloaded | 5@loaded.com         | brush     | brush       |
      | Watermelon         | name: Gleason   | 1@biker.com          | jumper    | jumper      |
      | Bruce Springsteen  | name: Gleason   | 2@biker.com          | airairair | airairair   |
      | Barnaby Watson     | name: Gleason   | 3@biker.com          | mypeeps   | mypeeps     |
      | Charlie Moore      | name: Gleason   | 4@biker.com          | livingit  | livingit    |
      | Already Playing    | name: Bratwurst | playing@inviting.com | playing   | playing     |

    Given the following claimed user exists:
      | name       | demo            | email                       | slug      | sms_slug    | phone_number |
      | Barnaby    | name: Bratwurst | claimed@inviting.com        | smoke     | smoke       | +15554445555 |
      | Alexander  | name: Bratwurst | also_claimed@inviting.com   | soap      | soap        | +15554442222 |
      | Outsider   | name: Gleason   | different_game@inviting.com | box       | box         | +15554442211 |
      | Shelly     | name: Preloaded | pre@loaded.com              | nada      | nada        | +16662221111 |
      | Yoko       | name: NotStarted| not@started.com             | abb       | abb         | +13384848484 |

  @javascript
  Scenario: Invite friends on demo pre-populated with users
    Given "Shelly" has the password "foobar"
    Given I sign in via the login page as "Shelly/foobar"    
    Then I should see "Invite your friends"
    When I fill in "Enter part of their name or email address" with "bra"
    Then I should see "Charlie Brainfield"
    When I select the suggestion containing "Charlie Brainfield"
    And I follow "Invite!"
    Then I should see "You just invited Charlie Brainfield to play H Engage"
    And DJ cranks 5 times
    Then "1@loaded.com" should receive an email
    When "1@loaded.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "1@loaded.com"
    When I fill in "Enter your mobile number" with "2088834848"
    And I fill in "Enter your name" with "Blowing Smoke"
    And I fill in "Choose a unique ID" with "somereallylongtextstring"
    And I fill in "Choose a password" with "password"
    And I fill in "And confirm that password" with "password"
    And I press "Join the game"
    And I wait a second
    Then I should see "Brought to you by"
    Then user with email "1@loaded.com" should show up as referred by "Shelly"
    And DJ cranks 5 times
    And I dump all sent texts
    And "+16662221111" should have received SMS "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!"
    And I should see "Shelly got credit for referring Blowing Smoke to the game"
    And I should see "2000 pts"


  @javascript
  Scenario: Invite multiple friends at a time on demo pre-populated with users
    Given "Shelly" has the password "foobar"
    Given I sign in via the login page as "Shelly/foobar"    
    Then I should see "Invite your friends"
    When I fill in "Enter part of their name or email address" with "bra"
    Then I should see "Charlie Brainfield"
    When I select the suggestion containing "Charlie Brainfield"
    Then I should see "That's 2000 potential bonus points!"
    When I fill in "Enter part of their name or email address" with "our"
    Then I should see "Fourfold"
    When I select the suggestion containing "Fourfold"
    And I should see "That's 4000 potential bonus points!"

    And I follow "Invite!"
    Then I should see "You just invited Charlie Brainfield and Fourfold to play H Engage"
    And DJ cranks 5 times
    
    # Check that first invitee received email
    Then "4@loaded.com" should receive an email
    When "4@loaded.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "4@loaded.com"
    
    # Check that second invitee received email and can join game
    Then "1@loaded.com" should receive an email
    When "1@loaded.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "1@loaded.com"
    When I fill in "Enter your mobile number" with "2088834848"
    And I fill in "Enter your name" with "Blowing Smoke"
    And I fill in "Choose a unique ID" with "somereallylongtextstring"
    And I fill in "Choose a password" with "password"
    And I fill in "And confirm that password" with "password"
    And I press "Join the game"
    And I wait a second
    Then I should see "Brought to you by"
    Then user with email "1@loaded.com" should show up as referred by "Shelly"
    And DJ cranks 5 times
    And I dump all sent texts
    And "+16662221111" should have received SMS "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!"
    And I should see "Shelly got credit for referring Blowing Smoke to the game"
    And I should see "2000 pts"





  @javascript
  Scenario: Invite one friend on a demo with a self-inviting domain
    Given "Barnaby" has the password "foobar"
    Given I sign in via the login page as "Barnaby/foobar"    
    Then I should see "Invite your friends"
    When I fill in "email number 1" with "racing22"
    And I press "Invite!"
    Then I should see "You just invited racing22@inviting.com to play H Engage"
    And DJ cranks 5 times
    Then "racing22@inviting.com" should receive an email
    When "racing22@inviting.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "racing22@inviting.com"
    When I fill in "Enter your mobile number" with "2088834848"
    And I fill in "Enter your name" with "Blowing Smoke"
    And I fill in "Choose a unique ID" with "somereallylongtextstring"
    And I fill in "Choose a password" with "password"
    And I fill in "And confirm that password" with "password"
    And I press "Join the game"
    And I wait a second
    Then I should see "Brought to you by"
    Then user with email "racing22@inviting.com" should show up as referred by "Barnaby"
    And DJ cranks 5 times
    And I dump all sent texts
    And "+15554445555" should have received SMS "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!"
    And I should see "Barnaby got credit for referring Blowing Smoke to the game"
    And I should see "2000 pts"
    
  @javascript
  Scenario: Invite multiple friends at a time on a demo with a self-inviting domain
    Given "Barnaby" has the password "foobar"
    Given I sign in via the login page as "Barnaby/foobar"   
    Then I should see "Invite your friends"
    When I fill in "email number 0" with "racing01"
    And I should see "That's 2000 potential bonus points!"
    When I fill in "email number 1" with "racing02"
    And I should see "That's 4000 potential bonus points!"
    When I fill in "email number 2" with "racing03"
    When I fill in "email number 3" with "racing04"
    When I fill in "email number 4" with "racing05"
    
    And I press "Invite!"
    Then I should see "You just invited racing01@inviting.com, racing02@inviting.com, racing03@inviting.com, racing04@inviting.com, and racing05@inviting.com to play H Engage"
    And DJ cranks 15 times
    Then "racing03@inviting.com" should receive an email
    When "racing03@inviting.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "racing03@inviting.com"
    When I fill in "Enter your mobile number" with "2084334848"
    And I fill in "Enter your name" with "Blowing Smoke"
    And I fill in "Choose a unique ID" with "somereallylongtextstring"
    And I fill in "Choose a password" with "password"
    And I fill in "And confirm that password" with "password"
    And I press "Join the game"
    And I wait a second
    Then I should see "Brought to you by"
    Then user with email "racing03@inviting.com" should show up as referred by "Barnaby"
    And DJ cranks 5 times
    And I dump all sent texts
    And "+15554445555" should have received SMS "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!"
    And I should see "Barnaby got credit for referring Blowing Smoke to the game"
    And I should see "2000 pts"
    
    
  @javascript
  Scenario: user invites someone who already accepted an invitation
    Given "Barnaby" has the password "foobar"
    Given I sign in via the login page as "Barnaby/foobar"    
    Then I should see "Invite your friends"
    When I fill in "email number 3" with "also_claimed"
    And I press "Invite!"
    Then I should not see "You just invited"
    And I should see "Thanks, but the following users are already playing the game: also_claimed@inviting.com"
  
  @javascript
  Scenario: modal pops up the first two times I log in
    Given the demo for "NotStarted" starts tomorrow
    And "Yoko" has the password "foobar"
    And I sign in via the login page as "Yoko/foobar"
    Then I should see "Invite your friends" in a facebox modal
    Given I go to the activity page
    Then I should not see a facebox modal
    And I sign out
    And I sign in via the login page as "Yoko/foobar"
    Then I should see "Invite your friends" in a facebox modal
    And I sign out
    And I sign in via the login page as "Yoko/foobar"
    Then I should not see a facebox modal
    
  @javascript
  Scenario: invitation actually sent when using the modal
    Given the demo for "NotStarted" starts tomorrow
    And "Yoko" has the password "foobar"
    And I sign in via the login page as "Yoko/foobar"
    Then I should see "Invite your friends" in a facebox modal
    When I fill in "email number 3" with "mybestfriend"
    And I press "Invite!"
    And I should see "You just invited mybestfriend@started.com to play H Engage"
    
    
  @javascript
  Scenario: Proper error messages for inviting people on a self-inviting domain
    Given "Barnaby" has the password "foobar"
    Given I sign in via the login page as "Barnaby/foobar"   
    Then I should see "Invite your friends"
    When I fill in "email number 0" with "also_claimed"
    And I should see "That's 2000 potential bonus points!"
    And I press "Invite!"
    And I should see "Thanks, but the following users are already playing the game: also_claimed@inviting.com"
    
    When I fill in "email number 0" with "neverheardofyou"
    And I should see "That's 2000 potential bonus points!"
    And I press "Invite!"
    And I should see "You just invited neverheardofyou@inviting.com to play H Engage"
    And I should see "That's 2000 potential bonus points!"
    And there should be a user with email "neverheardofyou@inviting.com" in demo "Bratwurst"
    
    When I fill in "email number 0" with "different_game"
    And I should see "That's 2000 potential bonus points!"
    And I press "Invite!"
    And I should see "Thanks, but different_game@inviting.com is in a different game than you"
    And I should not see "That's 2000 potential bonus points!"
    
    When I fill in "email number 0" with "different_game"
    And I should see "That's 2000 potential bonus points!"
    And I press "Invite!"
    And I should see "Thanks, but different_game@inviting.com is in a different game than you"
    And I should not see "That's 2000 potential bonus points!"
