Feature: Password reset
  In order to sign in even if user forgot their password
  A user
  Should be able to reset it

  Scenario: User is signed up and requests password reset
    Given I am a claimed user who signed up with "email@person.com/password"
    When I request password reset link to be sent to "email@person.com"
    Then I should see "You will receive an email"
    And a password reset message should be sent to "email@person.com"

  Scenario: Asking for a password reset is case insensitive
    Given I am a claimed user who signed up with "email@person.com/password"
    When I request password reset link to be sent to "EmAIl@peRSOn.cOm"
    Then I should see "You will receive an email"
    And a password reset message should be sent to "email@person.com"

  Scenario: User is signed up updated his password and types wrong confirmation
    Given I am a claimed user who signed up with "email@person.com/password"
    And I go to the password reset request page
    And I fill in the reset email field with "email@person.com"
    And I press "Reset password"
    When I follow the password reset link sent to "email@person.com"
    And I update my password with "newpassword/wrongconfirmation"
    Then I should not see "1 error prohibited this user from being saved"
    But I should see "Sorry, your passwords don't match"
    And I should be signed out

  Scenario: Password and confirmation are blanked out on bad confirmation
    Given I am a claimed user who signed up with "email@person.com/password"
    And I go to the password reset request page
    And I fill in the reset email field with "email@person.com"
    And I press "Reset password"
    When I follow the password reset link sent to "email@person.com"
    And I update my password with "newpassword/wrongconfirmation"
    Then the password field should be blank
    And the password confirmation field should be blank

  Scenario: User is signed up and updates his password
    Given I am a claimed user who signed up with "email@person.com/password"
    And I go to the password reset request page
    And I fill in the reset email field with "email@person.com"
    And I press "Reset password"
    When I follow the password reset link sent to "email@person.com"
    And I update my password with "newpassword/newpassword"
    Then I should be signed in
    When I sign out
    Then I should be signed out
    And I sign in as "email@person.com/newpassword"
    Then I should be signed in

  Scenario: User tries to update with an under-length password
    Given I am a claimed user who signed up with "email@person.com/password"
    And I go to the password reset request page
    And I fill in the reset email field with "email@person.com"
    And I press "Reset password"
    When I follow the password reset link sent to "email@person.com"
    And I update my password with "12345/12345"
    Then I should see "Password must have at least 6 characters"
    When I sign in as "email@person.com/12345"
    Then I should be signed out
    When I sign in as "email@person.com/password"
    Then I should be signed in

  Scenario: User tries using the same password reset token twice
    Given I am a claimed user who signed up with "email@person.com/password"
    And I go to the password reset request page
    And I fill in the reset email field with "email@person.com"
    And I press "Reset password"
    When "email@person.com" opens the email
    And I follow "Change password" in the email
    And I update my password with "newpassword/newpassword"
    Then I should be signed in

    When I sign out
    And I follow "Change password" in the email
    Then I should be on the password reset request page
    And I should see "For security reasons, you can use each password reset link just once. If you'd like to reset your password again, please request a new link from this form."
