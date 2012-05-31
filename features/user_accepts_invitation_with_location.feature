Feature: User accepts invitation and specifies location

  Scenario: User for demo with locations can choose one when accepting invitation
    Given the following demo exists:
      | name |
      | LocatoCo     |
    And the following locations exist:
      | name          | demo                   |
      | Alphaville    | name: LocatoCo |
      | Betaville     | name: LocatoCo |
      | Gammaville    | name: LocatoCo |
      | Deltaville    | name: LocatoCo |
    And the following user exists:
      | email           | name | demo                   |
      | joe@example.com | Joe  | name: LocatoCo |
      | bob@example.com | Bob  | name: LocatoCo |
    And "joe@example.com" has received an invitation
    And "bob@example.com" has received an invitation

    When I sign in via the login page as an admin
    And I go to the admin "LocatoCo" user-by-location page
    Then I should see "Gammaville 0"

    When "joe@example.com" opens the email
    And I click the play now button in the email
    Then I should be on the invitation page for "joe@example.com"
    When I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I check "Terms and conditions"
    And I press "Join the game"
    Then I should be on the activity page
    And I should see "Joe joined the game less than a minute ago"

    When "bob@example.com" opens the email
    And I click the play now button in the email
    Then I should be on the invitation page for "bob@example.com"
    When I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I select "Gammaville" from "Location"
    And I check "Terms and conditions"
    And I press "Join the game"
    Then I should be on the activity page
    And I should see "Bob joined the game less than a minute ago"

    When I sign in via the login page as an admin
    And I go to the admin "LocatoCo" user-by-location page
    Then I should see "Gammaville 1"
