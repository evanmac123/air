Feature: User requests an invitation via SMS

  Background:
  Given the following demo exists:
    | name | email                      |
    | BrandyWine   | brandywine@playhengage.com |
  Given the following self inviting domain exists:
    | domain      | demo                     |
    | example.com | name: BrandyWine |

    And "+14155551213" sends SMS "email@example.com"

  Scenario: User texts us email address, gets an invitation, and fills it out
    Then "+14155551213" should have received an SMS "An invitation has been sent to email@example.com."
    And "email@example.com" should receive an email
    When "email@example.com" opens the email
    And they click the first link in the email
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


  Scenario: We remember that user's phone number is pre-confirmed even if the acceptance process takes several tries
    When "email@example.com" opens the email
    And they click the first link in the email
    And I should not see "Enter your mobile number"

    When I press "Join the game"
    Then I should see "Please choose a password"
    And I should not see "Enter your mobile number"
    
  Scenario: Invitation comes from proper email address
    When "email@example.com" opens the email
    Then they should see the email delivered from "BrandyWine <brandywine@playhengage.com>"
