Feature: Admin edits users
  Background:
    Given the following demo exists:
      | company_name      |
      | British Petroleum |
    And the following users exist:
      | name | email      | claim_code | demo                            |
      | Bob  | bob@bp.com | bp_bob     | company_name: British Petroleum |
    And I sign in as an admin via the login page
    And I am on the admin "British Petroleum" demo page
    And I follow "B"
    And I follow "(edit Bob)"

  Scenario: Admin edits users
    When I fill in "Name" with "Bobby"
    And I fill in "Email" with "bobby@bp.com"
    And I fill in "Claim code" with "bp_bobby"
    And I fill in "Connection bounty" with "7"
    And I press "Update User"
    Then I should be on the admin "British Petroleum" demo page

    When I follow "B"
    Then I should see "Bobby, bobby@bp.com (bp_bobby) (connection bounty: 7 points)"

  Scenario: Admin removes claim code
    When I fill in "Claim code" with ""
    And I press "Update User"
    Then I should be on the admin "British Petroleum" demo page
    And I should not see "bobby@bp.com ()"
