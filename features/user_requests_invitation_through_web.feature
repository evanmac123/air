Feature: User sends herself an invitation

  Background:
    Given the following demos exist:
      | name            | 
      | Highmark        |
      | PrePopulatedFun |
    And the following claimed users exist:
      | email            | demo           |
      | joe@highmark.com | name: Highmark |
    And the following users exist:
      | email               | demo                     |
      | fred@highmark.com   | name: Highmark           |
      | bob@somedomain.com  | name: PrePopulatedFun    |

    And I go to the new invitation page
    
    
 
  Scenario: Claimed user can't invite self with a duplicate email, but unclaimed treats it as a request for re-invitation
    When I fill in "invitation_request_email" with "joe@highmark.com"
    And I press "Request invitation"
    Then I should see "That e-mail address is already taken. If this is your address, and you've already requested an invitation but lost the invitation e-mail, you can request for it to be re-sent here. If you've already been invited and then joined the game, you can log in here, or have your password reset if you've forgotten it here. You can also contact support@airbo.com for help."

    When I fill in "invitation_request_email" with "fred@highmark.com"
    And I press "Request invitation"
    Then I should see "We've received your request for an invitation. You should receive an invitation e-mail at fred@highmark.com shortly. If you haven't received this e-mail within a few minutes, please request for it to be re-sent here, or contact support@airbo.com for help."

    When DJ cranks 10 times
    Then "joe@highmark.com" should receive no email
    But "fred@highmark.com" should receive an email
    When "fred@highmark.com" opens the email
    And I click the play now button in the email
    Then I should be on the activity page

  Scenario: Pre Populated user can request invitation
    When I fill in "invitation_request_email" with "bob@somedomain.com"
    And I press "Request invitation"
    Then I should see "We've received your request for an invitation. You should receive an invitation e-mail at bob@somedomain.com shortly. If you haven't received this e-mail within a few minutes, please request for it to be re-sent here, or contact support@airbo.com for help."
    When DJ cranks 10 times
    Then "bob@somedomain.com" should receive an email
    When "bob@somedomain.com" opens the email
    And I click the play now button in the email
    Then I should be on the activity page
