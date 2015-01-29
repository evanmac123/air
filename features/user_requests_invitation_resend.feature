Feature: User requests their invitation email to be resent

  Background:
    Given the following users exist:
      | name | email            | invited | accepted invitation at       |
      | Joe  | joe@example.com  | true    |                              |
      | Bob  | bob@example.com  | false   |                              |
      | Fred | fred@example.com | true    | 2011-01-01 00:00             |
    And I go to the invitation resend page

  Scenario: User requests their invitation email to be resent
    When I fill in "Email" with "joe@example.com"
    And I press "Re-send invitation"

    Then I should be on the invitation resend page
    And I should see "We've resent your invitation to joe@example.com."
    And "joe@example.com" should receive 1 email

    When "joe@example.com" opens the email
    And I click the play now button in the email
    Then I should be on the activity page

  Scenario: User requests invitation to be resent from a non-invited account
    When I fill in "Email" with "bob@example.com"
    And I press "Re-send invitation"
    Then I should be on the invitation resend page
    And I should see "It looks like you haven't been invited yet. You can request an invitation here, or contact support@airbo.com for help." 
    And "bob@example.com" should receive no email

    When I fill in "Email" with "nobody@nowhere.com"
    And I press "Re-send invitation"
    Then I should be on the invitation resend page
    And I should see "It looks like you haven't been invited yet. You can request an invitation here, or contact support@airbo.com for help." 
    And "nobody@nowhere.com" should receive no email

  Scenario: User requestes invitation to be resent to an account already joined
    When I fill in "Email" with "fred@example.com"
    And I press "Re-send invitation"

    Then I should be on the invitation resend page
    And I should see "It looks like you've already joined the game. You can log in here, or if you've forgotten your password, you can reset it here."
    And "fred@example.com" should receive no email
