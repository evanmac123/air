Feature: User claims account via email

  Background:
    Given the following demo exists:
      | company name | custom welcome message |
      | FooCo        | We own you             |
    And the following users exist:
      | name | email           | claim code | demo                |
      | Joe  | joe@example.com | joe        | company_name: FooCo |
      | Bob  | bob@example.com | bob        | company_name: FooCo |

  Scenario: User claims account
    When "joe@example.com" sends email with subject "yo yo" and body "joe"
    Then "joe@example.com" should receive 1 email

    When "joe@example.com" opens the email
    Then I should see "We own you" in the email body
    Then I should see the password reset full URL for "Joe" in the email body
    And I should see the profile page full URL for "Joe" in the email body

    When I click the first link in the email
    And I fill in "Choose password" with "joey"
    And I fill in "Confirm password" with "joey"
    And I press "Save this password"
    Then I should be on the activity page

    When I sign out
    And I sign in via the login page with "Joe/joey"
    Then I should be on the activity page

    When I go to the profile page for "Joe"
    Then I should see "(999) 555-0000"

  Scenario: User claims account, email doesn't match claim code
    When "joe@example.com" sends email with subject "yo yo" and body "oooooooooohyeaaaaaaaaaah"
    Then "joe@example.com" should receive 1 email

    When "joe@example.com" opens the email
    Then I should see "That user ID doesn't match the one we have in our records. Please try again, or email help@hengage.com for assistance from a human." in the email body
