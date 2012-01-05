Feature: User can change their location

  Background:
    Given the following demo exists:
      | company_name |
      | BitBytes     |
    Given the following locations exist:
      # Note that the location must be bound to the demo, or it won't show up in the select tag
      | name         | demo |
      | Philadelphia | company_name: BitBytes |
    Given the following users exists:
      | name | location           | demo                   |
      | Phil | name: Philadelphia | company_name: BitBytes |



    And "Phil" has password "foo"
    And I sign in via the login page with "Phil/foo"

  Scenario:
    When I go to the profile page for "Phil"
    Then I should see 'Location'
    When I select "Philadelphia" from the location drop-down
    And I press the button to save the new location
    Then I should see "Philadelphia"
    And I should see "OK, your location is now Philadelphia."
