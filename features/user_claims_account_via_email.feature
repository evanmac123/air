Feature: User claims account via email

  Background:
    Given the following demo exists:
      | name  |
      | FooCo |
    And the following users exist:
      | name | email           | claim code | demo        |
      | Joe  | joe@example.com | joe        | name: FooCo |
      | Bob  | bob@example.com | bob        | name: FooCo |

  Scenario: User claims account
    When "joe@example.com" sends email with subject "yo yo" and body "joe"
    Then "joe@example.com" should receive 1 email

    When "joe@example.com" opens the email
    Then I should see "You've joined the FooCo game! Your username is joe (text MYID if you forget). To play, reply to this email with your command. OR you should have received another email from us with instructions for how to log into the web site." in the email body
    But I should not see "text to this #" in the email body
    Then I should see the password reset full URL for "Joe" in the email body
    And I should see the profile page full URL for "Joe" in the email body

    When I click the first link in the email
    And I fill in "Choose password" with "joejums"
    And I fill in "Confirm password" with "joejums"
    And I press "Save this password"
    Then I should be on the activity page

    When I sign out
    And I sign in via the login page with "Joe/joejums"
    Then I should be on the activity page

  Scenario: User claims account in a game with custom welcome message
    Given the following demo exists:
      | name     | custom welcome message |
      | CustomCo | We own you.            |
    And the following users exist:
      | name | email            | claim code | demo           |
      | Fred | fred@example.com | fred       | name: CustomCo |
    When "fred@example.com" sends email with subject "yo yo" and body "fred"
    Then "fred@example.com" should receive 1 email

    When "fred@example.com" opens the email
    Then I should see "We own you" in the email body
 
  Scenario: User claims account, email doesn't match claim code
    When "joe@example.com" sends email with subject "yo yo" and body "oooooooooohyeaaaaaaaaaah"
    Then "joe@example.com" should receive 1 email

    When "joe@example.com" opens the email
    Then I should see "That username doesn't match the one we have in our records. Please try again, or email help@hengage.com for assistance from a human." in the email body

  Scenario: User tries to claim account but email body is blank
    When "joe@example.com" sends email with subject "sign me up homeslice" and body ""
    Then "joe@example.com" should receive 1 email

    When "joe@example.com" opens the email
    Then I should see "We got your email, but it looks like the body of it was blank. Please put your command in the first line of the email body." in the email body

  Scenario: User claims account that's already claimed
    Given the following user exists:
      | name | email            | claim code | accepted_invitation_at | demo                |
      | Fred | fred@example.com | fred       | 2011-01-01 00:00:00    | name: FooCo |
    And "joe@example.com" sends email with subject "hey" and body "fred"
    And DJ cranks 5 times

    When "joe@example.com" opens the email
    Then I should see "That ID fred is already taken. If you're trying to register your account, please send in your own ID first by itself in the body of an email." in the email body
    And I should not see "Please reply to this email in order to submit commands for points." in the email body
