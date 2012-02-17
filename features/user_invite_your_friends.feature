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
      | seconds.com  | name: Bratwurst  |
      | inviting.com | name: Bratwurst  |
      | biker.com    | name: Gleason    |
      | started.com  | name: NotStarted |

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

    Given the following claimed user exists:
      | name       | demo            | email                       | slug      | sms_slug    | phone_number | privacy level |
      | Barnaby    | name: Bratwurst | claimed@inviting.com        | smoke     | smoke       | +15554445555 | everybody     |
      | Alexander  | name: Bratwurst | also_claimed@inviting.com   | soap      | soap        | +15554442222 | everybody     |
      | Outsider   | name: Gleason   | different_game@inviting.com | box       | box         | +15554442211 | everybody     |
      | Shelly     | name: Preloaded | pre@loaded.com              | nada      | nada        | +16662221111 | everybody     |
      | Michelle   | name: Preloaded | playing@loaded.com          | sexy      | sexy        | +16662221199 | everybody     |
      | Yoko       | name: NotStarted| not@started.com             | abb       | abb         | +13384848484 | everybody     |


  @javascript
  Scenario: Status messages when inviting friends on a pre-populated demo
    Given "Shelly" has the password "foobar"
    Given I sign in via the login page as "Shelly/foobar"    
    Then I should see "Invite your friends"
    When I fill in "Which coworkers do you wish to invite?" with "br"
    Then "3+ letters" should be visible
    When I fill in "Which coworkers do you wish to invite?" with "jdidillvididkkemmffii"
    Then I should not see "3+ letters, please"
    And I should see "Hmmm...no match"
    And I should see "Please try again"
    When I fill in "Which coworkers do you wish to invite?" with "bra"
    Then I should see "Click on the person you want to invite:"
    Then I should see "Charlie Brainfield"
    And I should not see "Yo Yo Ma"

    
  @javascript
  Scenario: Invite friends on demo pre-populated with users
    Given "Shelly" has the password "foobar"
    Given I sign in via the login page as "Shelly/foobar"    
    Then I should see "Invite your friends"
    When I fill in "Which coworkers do you wish to invite?" with "bra"
    Then I should see "Charlie Brainfield"
    When I select the suggestion containing "Charlie Brainfield"
    And I follow "Invite selected users"
    Then I should see "You just invited Charlie Brainfield to play H Engage"
    And DJ cranks 5 times
    Then "1@loaded.com" should receive an email
    When "1@loaded.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "1@loaded.com"
    When I fill in "Enter your mobile number" with "2088834848"
    And I fill in "Enter your name" with "Blowing Smoke"
    And I fill in "Choose a username" with "somereallylongtextstring"
    And I fill in "Choose a password" with "password"
    And I fill in "And confirm that password" with "password"
    And I check "Terms and conditions"
    And I press "Join the game"
    And I wait a second
    Then I should see "Brought to you by"
    Then user with email "1@loaded.com" should show up as referred by "Shelly"
    And DJ cranks 5 times
    And "+16662221111" should have received SMS "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!"
    When "pre@loaded.com" opens the email
    Then I should see "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!" in the email body
    When I follow "Confirm my mobile number later"
    And I should see "Shelly got credit for referring Blowing Smoke to the game"
    And I should see "2000 pts"
    
    @javascript
    Scenario: Claimed users on a pre-pop game should not receive an invitation
      Given "Shelly" has the password "foobar"
      Given I sign in via the login page as "Shelly/foobar"    
      Then I should see "Invite your friends"
      When I fill in "Which coworkers do you wish to invite?" with "mic"
      Then I should see "Michelle"
      When I select the suggestion containing "Michelle"
      And I follow "Invite selected users"
      Then I should see "Michelle is already playing"
      And DJ cranks 5 times
      Then "playing@loaded.com" should receive no email
      
  @javascript
  Scenario: Invite multiple friends at a time on demo pre-populated with users
    Given "Shelly" has the password "foobar"
    Given I sign in via the login page as "Shelly/foobar"    
    Then I should see "Invite your friends"
    When I fill in "Which coworkers do you wish to invite?" with "bra"
    Then I should see "Charlie Brainfield"
    When I select the suggestion containing "Charlie Brainfield"
    Then I should see "+2000 potential bonus points!"
    When I fill in "Which coworkers do you wish to invite?" with "our"
    Then I should see "Fourfold"
    When I select the suggestion containing "Fourfold"
    And I should see "+4000 potential bonus points!"

    And I follow "Invite selected users"
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
    And I fill in "Choose a username" with "somereallylongtextstring"
    And I fill in "Choose a password" with "password"
    And I fill in "And confirm that password" with "password"
    And I check "Terms and conditions"
    And I press "Join the game"
    And I wait a second
    When I follow "Confirm my mobile number later"
    Then I should see "Brought to you by"
    Then user with email "1@loaded.com" should show up as referred by "Shelly"
    And DJ cranks 5 times
    And "+16662221111" should have received SMS "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!"
    When "pre@loaded.com" opens the email
    Then I should see "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!" in the email body
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
    And I fill in "Choose a username" with "somereallylongtextstring"
    And I fill in "Choose a password" with "password"
    And I fill in "And confirm that password" with "password"
    And I check "Terms and conditions"
    And I press "Join the game"
    And I wait a second
    Then I should see "Brought to you by"
    Then user with email "racing22@inviting.com" should show up as referred by "Barnaby"
    And DJ cranks 5 times
    And "+15554445555" should have received SMS "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!"
    When "claimed@inviting.com" opens the email
    Then I should see "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!" in the email body
    When I follow "Confirm my mobile number later"
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
    And I fill in "Choose a username" with "somereallylongtextstring"
    And I fill in "Choose a password" with "password"
    And I fill in "And confirm that password" with "password"
    And I check "Terms and conditions"
    And I press "Join the game"
    And I wait a second
    Then I should see "Brought to you by"
    Then user with email "racing03@inviting.com" should show up as referred by "Barnaby"
    And DJ cranks 5 times
    And "+15554445555" should have received SMS "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!"
    When "claimed@inviting.com" opens the email
    Then I should see "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!" in the email body
    When I follow "Confirm my mobile number later"
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


  @javascript
  Scenario: Throw an error if you put an @ symbol in the email prepend
    Given "Barnaby" has the password "foobar"
    Given I sign in via the login page as "Barnaby/foobar"    
    Then I should see "Invite your friends"
    When I fill in "email number 1" with "racing22@harmony.com"
    And I press "Invite!"
    Then I should see `Please enter only the part of the email address before the "@" - and remember that only colleagues in your organization can play.`

  @javascript
  Scenario: User should not be able to invite herself
    Given "Yo Yo Ma" has the password "yummies"
    Given I sign in via the login page as "Yo Yo Ma/yummies"    
    Then I should see "Invite your friends"
    When I fill in "Which coworkers do you wish to invite?" with "loaded"
    Then I should see "Charlie Brainfield"
    And I should not see "Yo Yo Ma" within the suggested users
    
  @javascript
  Scenario: When demo has to self-inviting domains, use the correct one
    Given "Barnaby" has the password "foobar"
    Given I sign in via the login page as "Barnaby/foobar"  
    Then I should see "Invite your friends"
    Then I should not see "seconds.com" 
    When I fill in "email number 1" with "racing22"
    And I press "Invite!"
    Then I should see "You just invited racing22@inviting.com to play H Engage"
    Then I should not see "seconds.com"    
    And DJ cranks 5 times
    Then "racing22@inviting.com" should receive an email
