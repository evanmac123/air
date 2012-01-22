Feature: Marketing page login dropdown works

 @javascript @slow
 Scenario: User logs in with correct email/password
   Given the following user exists:
     | name  | email             |
     | Jimbo | jimbo@example.com |
   And "Jimbo" has password "bigjim"
   When I go to the home page
   And I press the button to activate the login dropdown
   And I fill in the login dropdown email field with "jimbo@example.com"
   And I fill in the login dropdown password field with "bigjim"
   And I check the remember-me checkbox
   And I press the "go" button in the login dropdown
   Then I should be on the activity page
   And I should not see "Signed in."

   And I should not see "Your game begins on May 01, 2011 at 12:00 AM Eastern"
