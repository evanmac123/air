Feature: Admin resends invitation to user

  @javascript
  Scenario: Admin resends invitation to user
    Given the following user exists:
      | name | email           | invited | invitation_code | demo                   |
      | Joe  | joe@example.com | true    | invitemeplzthx  | company_name: InviteCo |
    And the following site admin exists:
      | name |
      | Bob  |
    And "Bob" has the password "foo"
    When I sign in via the login page with "Bob/foo"
    And I go to the admin "InviteCo" demo page
    And I follow "J"
    And I follow "Re-send invitation"

    Then "joe@example.com" should receive 1 email
    When "joe@example.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "joe@example.com"
