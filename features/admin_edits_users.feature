Feature: Admin edits users

  Background:
    Given the following demo exists:
      | name              |
      | British Petroleum |
    And the following users exist:
      | name | email      | claim_code | demo                    | new_phone_number | new_phone_validation |
      | Bob  | bob@bp.com | bp_bob     | name: British Petroleum | 617-666-6666     | 1234                 |
    When I sign in as an admin via the login page
      And I am on the admin "British Petroleum" demo page
      And I follow "B"
      And I follow "(edit Bob)"

  Scenario: Admin edits a user, both filling in and then clearing fields
    Then the Year listbox should contain the correct years
      And the "Phone number" field should be "blank"
      And the "Zip code" field should be "blank"
      And the "Month" field should be "blank"
      And the "Day" field should be "blank"
      And the "Year" field should be "blank"
    When I fill in "Name" with "Bobby"
      And I fill in "Email" with "bobby@bp.com"
      And I fill in "Phone number" with "666-666-6666"
      And I fill in "Zip code" with "12345"
      And I select "January" from "Month"
      And I select "1" from "Day"
      And I select "2000" from "Year"
      And I fill in "Claim code" with "bp_bobby"
      And I fill in "Connection bounty" with "7"
      And I press "Update User"
    Then I should be on the admin "British Petroleum" demo page
    When I follow "B"
      And I follow "(edit Bobby)"
    Then the "Name" field should be "Bobby"
      And the "Email" field should be "bobby@bp.com"
      And the "Phone number" field should be "(666) 666-6666"
      And the "Zip code" field should be "12345"
      And the "Month" listbox should be "January"
      And the "Day" listbox should be "1"
      And the "Year" listbox should be "2000"
      And the "Claim code" field should be "bp_bobby"
      And the "Connection bounty" field should be "7"
    When I fill in "Phone number" with ""
      And I fill in "Zip code" with ""
      And I select "" from "Month"
      And I select "" from "Day"
      And I select "" from "Year"
      And I fill in "Claim code" with ""
      And I press "Update User"
    Then I should be on the admin "British Petroleum" demo page
    When I follow "B"
      And I follow "(edit Bobby)"
    Then the "Phone number" field should be "blank"
      And the "Zip code" field should be "blank"
      And the "Month" field should be "blank"
      And the "Day" field should be "blank"
      And the "Year" field should be "blank"
      And the "Claim code" field should be "blank"

  Scenario: When admin enters a phone number for a user, it is internally converted and causes existing new-phone attributes to be cleared
    Then the new-phone attributes for "Bob" should not be blank
    When I fill in "Phone number" with "666-123-4567"
      And I press "Update User"
    Then the new-phone attributes for "Bob" should be blank
      And the phone-number attribute for "Bob" should be "+16661234567"
    When I follow "B"
      And I follow "(edit Bob)"
    Then the "Phone number" field should be "(666) 123-4567"

  Scenario: Admin entering invalid data for a user causes an error message to be displayed
    When I fill in "Zip code" with "12345-6789"
      And I press "Update User"
    Then I should be on the admin edits user "Bob" in the "British Petroleum" demo
    Then I should see "Couldn't update user: Zip code is invalid"