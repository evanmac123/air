Feature: User can change their name

  Background:
    Given the following users exists:
      | name |
      | Phil |
    And "Phil" has password "foo"
    And I sign in via the login page with "Phil/foo"
    And I go to the profile page for "Phil"

  Scenario: User changes their name
    When I fill in "Enter a new name" with "Bob"
    And I press the button to submit a new name
    Then I should see `OK, from now on we'll call you "Bob."`
    And I should not see "Phil"

  Scenario: User can't change their name to blank
    When I fill in "Enter a new name" with ""
    And I press the button to submit a new name
    Then I should see "Sorry, you can't change your name to something blank."
    And I should see "Phil"
