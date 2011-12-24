Feature: User accepts invitation and specifies location

  Background:
    Given the following demo exists:
      | company name |
      | LocatoCo     |
    And the following user exists:
      | email           | name | demo                   |
      | joe@example.com | Joe  | company_name: LocatoCo |
    And "joe@example.com" has received an invitation
    And "joe@example.com" opens the email

  Scenario: User for demo with locations must choose one when accepting invitation
    Given the following locations exist:
      | name          | demo                   |
      | Alphaville    | company_name: LocatoCo |
      | Betaville     | company_name: LocatoCo |
      | Gammaville    | company_name: LocatoCo |
      | Deltaville    | company_name: LocatoCo |

    When I sign in via the login page as an admin
    And I go to the admin "LocatoCo" user-by-location page
    Then I should see "Gammaville 0"

    When I click the first link in the email
    Then I should be on the invitation page for "joe@example.com"
    When I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I press "Join the game"

    Then I should be on the invitation page for "joe@example.com"
    And I should see "Please choose a password and location."

    When I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I select "Gammaville" from "Location"
    And I press "Join the game"

    Then I should be on the activity page
    And I should see "Joe joined the game less than a minute ago"

    When I sign in via the login page as an admin
    And I go to the admin "LocatoCo" user-by-location page
    Then I should see "Gammaville 1"

  Scenario: User accepts invitation for demo with no locations, and doesn't see dropdown for it
    When I click the first link in the email
    Then I should be on the invitation page for "joe@example.com"
    And I should not see "Location"

    When I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I press "Join the game"

    Then I should be on the activity page
    And I should see "Joe joined the game less than a minute ago"
