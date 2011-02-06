Feature: Not just anyone off the street can sign up

  Scenario: Not just anyone off the street can sign up
    Given I am not logged in
    When I go to the sign up page
    Then I should be on the static invitation page
