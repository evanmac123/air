Feature: User can change their mobile number

Background:
  Given the following users exists:
    | name | phone_number |
    | Bob  | +14155551212 |
    | Fred | +16178675309 |
  And "Bob" has the password "bobby"
  And I sign in via the login page as "Bob/bobby"

Scenario: User sees their mobile number on their profile
  When I go to the profile page for "Bob"
  Then I should see "Your mobile number: +14155551212"

Scenario: User doesn't see anyone else's mobile number
  When I go to the profile page for "Fred"
  Then I should not see "Your mobile number: +16178675309"
  And I should not see "change your mobile number"

Scenario: User can change your their own mobile number
  When I go to the profile page for "Bob"
  And I follow "change your mobile number"
  And I fill in "Enter your new mobile number" with "(900) 939-4956"
  And I press "Save new mobile number"
  Then I should be on the profile page for "Bob"
  And I should see "Your mobile number was updated."
  And I should see "Your mobile number: +19009394956"
