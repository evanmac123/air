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
    When I fill in "Email" with "joe@highmark.com"
    And I press "Request invitation"
    Then I should see "That e-mail address is already taken. If this is your address, and you've already requested an invitation but lost the invitation e-mail, you can request for it to be re-sent here. If you've already been invited and then joined the game, you can log in here, or have your password reset if you've forgotten it here. You can also contact support@hengage.com for help."

    When I fill in "Email" with "fred@highmark.com"
    And I press "Request invitation"
    Then I should see "We've received your request for an invitation. You should receive an invitation e-mail at fred@highmark.com shortly. If you haven't received this e-mail within a few minutes, please request for it to be re-sent here, or contact support@hengage.com for help."

    When DJ cranks 10 times
    Then "joe@highmark.com" should receive no email
    But "fred@highmark.com" should receive an email
    When "fred@highmark.com" opens the email
    And I click the play now button in the email
    Then I should be on the invitation page for "fred@highmark.com"

 
  Scenario: User has to specify an email address to invite self
    When I press "Request invitation"

    Then I should see "You must enter your e-mail address to request an invitation."
    
  Scenario: Pre Populated user can request invitation
    When I fill in "Email" with "bob@somedomain.com"
    And I press "Request invitation"
    Then I should see "We've received your request for an invitation. You should receive an invitation e-mail at bob@somedomain.com shortly. If you haven't received this e-mail within a few minutes, please request for it to be re-sent here, or contact support@hengage.com for help."
    When DJ cranks 10 times
    Then "bob@somedomain.com" should receive an email
    When "bob@somedomain.com" opens the email
    And I click the play now button in the email
    Then I should be on the invitation page for "bob@somedomain.com" 


############################################################################################
##################   SAVE FOR LATER FOR USE WITH PUBLIC JOIN GAME    --Jack ################
#  Scenario: User with an email in the proper domain invites themself
#    And I fill in "Email" with "chester@highmark.com"
#    And I press "Request invitation"
#    Then I should see "We've received your request for an invitation. You should receive an invitation e-mail at chester@highmark.com shortly. If you haven't received this e-mail within a few minutes, please request for it to be re-sent here, or contact support@hengage.com for help."
#
#    When DJ cranks 5 times
#    Then "chester@highmark.com" should receive an email
#    When "chester@highmark.com" opens the email
#    And I click the play now button in the email
#
#    Then I should be on the invitation page for "chester@highmark.com"
#    And I should see "Neither Highmark, its subsidiaries or agents, will be held responsible for any charges related to the use of the services."
#    When I fill in "Enter your mobile number" with "415-867-5309"
#    And I fill in "Enter your name" with "Chester Humphries"
#    And I fill in "Choose a password" with "foobar"
#    And I fill in "And confirm that password" with "foobar"
#    And I fill in "Choose a username" with "chester"
#
#    And I check "Terms and conditions"
#    And I press "Join the game"
#    And I follow "Confirm my mobile number later"
#    Then I should be on the activity page
#    And I should see "Chester Humphries joined the game"
#  Scenario: User can't invite self with a domain not allowed to do self-invitation
#    And I fill in "Email" with "chester@noway.com"
#    And I press "Request invitation"
#    Then I should see "Sorry, that e-mail domain noway.com is not one that's allowed to request invitations. You can contact support@hengage.com for help."
#
#    When DJ cranks 5 times
#    Then "chester@noway.com" should receive no email
#
