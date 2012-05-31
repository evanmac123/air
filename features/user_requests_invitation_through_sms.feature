Feature: User requests an invitation via SMS

  Background:
    Given the following demo exists:
      | name         | email                      |
      | BrandyWine   | brandywine@playhengage.com |
    And the following self inviting domain exists:
      | domain      | demo                            |
      | example.com | name: BrandyWine                |
      | example.example-nation.com | name: BrandyWine |
      
    And the following claimed user exists:
      | email           | demo             |
      | joe@example.com | name: BrandyWine |
    And the following user exists:
      | name      | email           | demo             |
      | Bob Smith | bob@example.com | name: BrandyWine |

  Scenario: User texts us email address, gets an invitation, and fills it out
    When "+14155551213" sends SMS " Email.Email-_@Example.com "
    Then "+14155551213" should have received an SMS "An invitation has been sent to email.email-_@example.com."
    And "email.email-_@example.com" should receive an email
    When "email.email-_@example.com" opens the email
    And I click the play now button in the email
    Then I should see "Choose a username"
    And I should not see "Enter your mobile number"
    And I should not see "We'll send you an SMS with instructions on the next step."
    And I should see "Name"

    When I fill in "Enter your name" with "Bobby Sapperstein"
    And I fill in "Choose a username" with "iambob"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I check "Terms and conditions"
    And I press "Join the game"
    Then I should be on the activity page
    And I should see "Bobby Sapperstein joined the game"

  Scenario: User on a weird-ass self-inviting domain gets a response
    When "+14155551213" sends SMS " forthright@example.example-nation.com "
    Then "+14155551213" should have received an SMS "An invitation has been sent to forthright@example.example-nation.com."
    
  Scenario: We remember that user's phone number is pre-confirmed even if the acceptance process takes several tries
    When "+14155551213" sends SMS "email@example.com"
    And "email@example.com" opens the email
    And I click the play now button in the email
    And I should not see "Enter your mobile number"

    When I press "Join the game"
    Then I should see "Please choose a password"
    And I should not see "Enter your mobile number"
    
  Scenario: Invitation comes from proper email address
    When "+14155551213" sends SMS "email@example.com"
    And "email@example.com" opens the email
    Then they should see the email delivered from "BrandyWine <brandywine@playhengage.com>"

  Scenario: Claimed user gets appropriate error if requesting invitation
    When "+14155551212" sends SMS "joe@example.com"
    And I dump all sent texts
    Then "+14155551212" should have received an SMS "It looks like you've already joined the game. If you've forgotten your password, you can have it reset online, or contact support@hengage.com for help."

  Scenario: Unclaimed user gets invitation resent if requesting invitation
    When "+14155551212" sends SMS "bob@example.com"
    And DJ cranks 5 times
    Then "bob@example.com" should receive an email
    When "bob@example.com" opens the email
    And I click the play now button in the email
    Then I should be on the invitation page for "bob@example.com"
    And "+14155551212" should have received an SMS "An invitation has been sent to bob@example.com."

  Scenario: Invitation request is not case sensitive
    When "+14155551212" sends SMS "BoB@ExaMPLe.COm"
    Then "+14155551212" should not have received an SMS including "Your domain is not valid"
    But "+14155551212" should have received an SMS "An invitation has been sent to bob@example.com."
