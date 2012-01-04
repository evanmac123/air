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
    # And I dump the page
    When I select "Philadelphia" from the location drop-down
    And I press the button to save the new location
    Then I should see "Philadelphia"

#  Scenario: User changes their name
#    When I fill in "Enter a new name" with "Bob"
#    And I press the button to submit a new name
#    Then I should see `OK, from now on we'll call you "Bob."`
#    And I should not see "Phil"

#  Scenario: User can't change their name to blank
#    When I fill in "Enter a new name" with ""
#    And I press the button to submit a new name
#    Then I should see "Sorry, you can't change your name to something blank."
#    And I should see "Phil"
