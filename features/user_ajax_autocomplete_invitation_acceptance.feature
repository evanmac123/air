Feature: User gives credit to game referer via autocomplete field

  Background:
    Given the following demo exists:
      | name |
      | Bratwurst    |
      | Gleason    |
    Given the following claimed users exist:
      | name               | demo                    | email        | slug      | sms_slug    |
      | Barnaby Bueller    | name: Bratwurst | 1@hopper.com | smoke     | smoke       |
      | Charlie Brainfield | name: Bratwurst | 2@hopper.com | airplane  | airplane    |
      | Yo Yo Ma           | name: Bratwurst | 3@hopper.com | naked     | naked       |
      | Threefold          | name: Bratwurst | 4@hopper.com | eraser    | eraser      |
      | Watermelon         | name: Gleason   | 1@biker.com  | jumper    | jumper      |
      | Bruce Springsteen  | name: Gleason   | 2@biker.com  | airairair | airairair   |
      | Barnaby Watson     | name: Gleason   | 3@biker.com  | mypeeps   | mypeeps     |
      | Charlie Moore      | name: Gleason   | 4@biker.com  | livingit  | livingit    |
    And the following users exist:
      | name               | demo            | email               | slug      | sms_slug    |
      | Charlie Smythe     | name: Bratwurst | 5@hopper.com        | smythe    | smythe      |
      | Luther Vandross    | name: Bratwurst | 6@harley.com        | luther    | luther      |
      | Gazpacho           | name: Bratwurst | 7@hopper.com        | hardly    | hardly      |
      | New User           | name: Bratwurst | new_user@hopper.com | newuser   | newuser     |
    When "new_user@hopper.com" has received an invitation
    And "new_user@hopper.com" opens the email
    And I click the play now button in the email
    Then I should see "And confirm that password"
    Then I should see "Did someone refer you?"

  @javascript
  Scenario: Status messages display and are not hidden
    When I fill in "Did someone refer you?" with "2"
    Then "3+ letters, please" should be visible
    And I should see "3+ letters, please"
    When I fill in "Did someone refer you?" with "jdidillvididkkemmffii"
    Then I should not see "3+ letters, please"
    And I should see "Hmmm...no match"
    And I should see "Please try again"
    When I fill in "Did someone refer you?" with "har"
    Then I should see "Click on the person who referred you:"
    Then I should see "Charlie Brainfield"
    And I should not see "Charlie Moore"
  
  @javascript
  Scenario: User sees the charlie from her own game when entering name 'har'
    When I fill in "Did someone refer you?" with "har"
    Then I should see "Charlie Brainfield"
    And I should not see "Charlie Moore"

  @javascript
  Scenario: User sees no users at all if text only matches other company_s email
    When I fill in "Did someone refer you?" with "bike"
    Then I should not see "Bruce Springsteen"
    And I should not see "Barnaby Bueller"

  @javascript
  Scenario: User sees users from her own game when searching on slug
    When I fill in "Did someone refer you?" with "air"
    Then I should see "Charlie Brainfield"
    And I should not see "Bruce Springsteen"

  @javascript
  Scenario: User sees only claimed users
    When I fill in "Did someone refer you?" with "har"
    Then I should see "Charlie Brainfield"
    But I should not see "Charlie Smythe"
    And I should not see "Luther Vandross"
    And I should not see "Gazpacho"

  @javascript
  Scenario: Field is populated with what the user clicks on
    When I fill in "Did someone refer you?" with "barnaby"
    Then I should see "Barnaby Bueller"
    And I should see "1@hopper.com"
    And I should see "smoke"
    When I select the suggestion containing "Barnaby Bueller"
    Then I should see "Barnaby Bueller"
    And I should not see "Charlie Brainfield"

  Scenario: When I submit with errors, I am brought back to the same page
    I should see "new_user@hopper.com"
    And I check "Terms and conditions"
    When I press "Join the game"
    Then I should see "I accept the"
    And I should see "terms & conditions"

  @javascript
  Scenario: When I select a referrer, then submit with errors, the referrer is still there
    When I fill in "Did someone refer you?" with "barnaby"
    Then I should see "Barnaby Bueller"
    When I select the suggestion containing "Barnaby Bueller"
    And I check "Terms and conditions"
    And I press "Join the game"
    Then I should see "Barnaby Bueller"

  @javascript
  Scenario: User can change her mind about which user referred her
  When I fill in "Did someone refer you?" with "barnaby"
  Then I should see "Barnaby Bueller"
  When I select the suggestion containing "Barnaby Bueller"
  And I follow "X"
  And I wait a second
  Then "Barnaby Bueller" should not be visible

  @javascript
  Scenario: Game referrer id gets saved to database
  When I fill in "Did someone refer you?" with "barnaby"
  Then I should see "Barnaby Bueller"
  When I select the suggestion containing "Barnaby Bueller"
  When I fill in "Enter your mobile number" with "2088834848"
  And I fill in "Enter your name" with "Blowing Smoke"
  And I fill in "Choose a username" with "somereallylongtextstring"
  And I fill in "Choose a password" with "password"
  And I fill in "And confirm that password" with "password"
  And I check "Terms and conditions"
  And I press "Join the game"
  And I wait a second
  Then I should see "Brought to you by"
  Then user with email "new_user@hopper.com" should show up as referred by "Barnaby Bueller"
