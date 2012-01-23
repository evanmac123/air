Feature: User gives credit to game referer via autocomplete field

  Background:
    Given the following demo exists:
      | company_name | game_referrer_bonus   |
      | Bratwurst    | 2000                  |
      | Gleason      | 2000                  |
    Given the following self inviting domain exists:
      | domain     | demo                    |
      | hopper.com | company_name: Bratwurst |
      | biker.com  | company_name: Gleason   |

    Given the following users exist:
      | name               | demo                    | email        | slug      | sms_slug    |
      | Charlie Brainfield | company_name: Bratwurst | 2@hopper.com | airplane  | airplane    |
      | Yo Yo Ma           | company_name: Bratwurst | 3@hopper.com | naked     | naked       |
      | Threefold          | company_name: Bratwurst | 4@hopper.com | eraser    | eraser      |
      | Watermelon         | company_name: Gleason   | 1@biker.com  | jumper    | jumper      |
      | Bruce Springsteen  | company_name: Gleason   | 2@biker.com  | airairair | airairair   |
      | Barnaby Watson     | company_name: Gleason   | 3@biker.com  | mypeeps   | mypeeps     |
      | Charlie Moore      | company_name: Gleason   | 4@biker.com  | livingit  | livingit    |

    Given the following claimed user exists:
      | name       | demo                    | email              | slug      | sms_slug    | phone_number |
      | Barnaby    | company_name: Bratwurst | claimed@hopper.com | smoke     | smoke       | +15554445555 |

    Given "Barnaby" has the password "foobar"
    Given I sign in via the login page as "Barnaby/foobar"

  @javascript
  Scenario:
    Then I should see "Invite your friends"
    When I fill in "Enter part of their name or email address" with "bra"
    Then I should see "Charlie Brainfield"
    When I select the suggestion containing "Charlie Brainfield"

    And I press "Invite!"
    Then I should see "You just invited Charlie Brainfield to play H Engage"
    And DJ cranks 5 times
    Then "2@hopper.com" should receive an email
    When "2@hopper.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "2@hopper.com"
    When I fill in "Enter your mobile number" with "2088834848"
    And I fill in "Enter your name" with "Blowing Smoke"
    And I fill in "Choose a unique ID" with "somereallylongtextstring"
    And I fill in "Choose a password" with "password"
    And I fill in "And confirm that password" with "password"
    And I press "Join the game"
    And I wait a second
    Then I should see "Brought to you by"
    Then user with email "2@hopper.com" should show up as referred by "Barnaby"
    And DJ cranks 5 times
    And I dump all sent texts
    And "+15554445555" should have received SMS "Blowing Smoke gave you credit for referring them to the game. Many thanks and 2000 bonus points!"
