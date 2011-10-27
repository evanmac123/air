Feature: User can choose a different SMS slug

  Background:
    Given the following user exists:
      | name | phone number |
      | Phil | +14155551212 |
    And "Phil" has the password "foo"
    And I sign in via the login page with "Phil/foo"
    And I go to the profile page for "Phil"

  Scenario: User changes SMS slug
    When I fill in "Enter a new username" with "awesomed00d"
    And I press the button to submit a new unique ID
    And "+14155551212" sends SMS "myid"
    Then I should see "Your user ID was changed to awesomed00d"
    And "+14155551212" should have received an SMS "Your user ID is awesomed00d."

  Scenario: User chooses an SMS slug that's already taken
    Given the following user exists:
      | name | phone number | 
      | Vlad | +14156171212 | 
    And "Vlad" has the SMS slug "awesomed00d"
    When I fill in "Enter a new username" with "awesomed00d"
    And I press the button to submit a new unique ID
    And "+14155551212" sends SMS "myid"
    Then I should see "Sorry, that user ID is already taken."
    And "+14155551212" should not have received an SMS including "awesomed00d"

  Scenario: User tries a blank SMS slug
    When I fill in "Enter a new username" with ""
    And I press the button to submit a new unique ID
    Then I should see "Sorry, you can't choose a blank user ID."
