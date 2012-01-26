Feature: Admin sets up self inviting domains for demo

  Background:
    Given the following demo exists:
      | name |
      | InviteCo     |
    And the following self inviting domains exist:
      | domain          | demo                   |
      | inviteco.com    | name: InviteCo |
      | foobar.com      | name: FooCo    |
    And the following site admin exists:
      | name |
      | Joe  |
    And "Joe" has password "foobar"
    And I sign in via the login page with "Joe/foobar"
    And I go to the admin "InviteCo" demo page
    And I follow "Self-inviting domains for this demo"
    Then I should see the self-inviting domain "inviteco.com"

  Scenario: Admin adds self inviting domain for demo
    When I fill in "Domain" with "invite.co.uk"
    And I press "Create Self inviting domain"
    Then I should be on the admin "InviteCo" self-inviting domain page
    And I should see the self-inviting domain "inviteco.com"
    And I should see the self-inviting domain "invite.co.uk"

  Scenario: Admin tries adding self inviting domain with blank name
    When I press "Create Self inviting domain"
    Then I should be on the admin "InviteCo" self-inviting domain page
    And I should see "Domain can't be blank"

  Scenario: Admin tries adding self inviting domain with duplicate name
    When I fill in "Domain" with "inviteco.com"
    And I press "Create Self inviting domain"
    Then I should be on the admin "InviteCo" self-inviting domain page
    And I should see "Domain has already been taken"

    When I fill in "Domain" with "foobar.com"
    And I press "Create Self inviting domain"
    Then I should be on the admin "InviteCo" self-inviting domain page
    And I should see "Domain has already been taken"
    And I should not see the self-inviting domain "foobar.com"

  Scenario: Admin deletes self-inviting demo
    When I press "Destroy inviteco.com"
    Then I should be on the admin "InviteCo" self-inviting domain page
    And I should see "inviteco.com destroyed"
    And I should not see the self-inviting domain "inviteco.com"
    But I should see "No self-inviting domains for this demo"
