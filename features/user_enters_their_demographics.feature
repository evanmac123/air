Feature: User enters their demographic info

  Background:
    Given the following user exists:
      | name |
      | Joe  |
    And "Joe" has the password "foo"
    When I sign in via the login page as "Joe/foo"
    And I go to the profile page for "Joe"

  Scenario: User enters their demographic information
    When I fill in "Weight (in pounds)" with "230"
    And I select "6" from "Feet"
    And I select "3" from "Inches"
    And I select "Male" from "Gender"
    And I select "1977-09-10" as the "Date of birth" date
    And I press the button to update demographic information

    Then I should be on the profile page for "Joe"
    And I should see "OK, your demographic information was updated."
    And "Weight" should have value "230"
    And "Feet" should have "6" selected
    And "Inches" should have "3" selected
    And "Gender" should have "Male" selected
    And "Year" should have "1977" selected
    And "Month" should have "9" selected
    And "Day" should have "10" selected

  Scenario: User enters only part of the height
    When I select "6" from "Feet"
    And I press the button to update demographic information
    Then I should be on the profile page for "Joe"
    And I should see "Please make a choice for both feet and inches of height."
    And "Feet" should have nothing selected
    And "Inches" should have nothing selected

    When I select "3" from "Inches"
    And I press the button to update demographic information
    Then I should be on the profile page for "Joe"
    And I should see "Please make a choice for both feet and inches of height."
    And "Feet" should have nothing selected
    And "Inches" should have nothing selected

    When I select "6" from "Feet"
    And I select "3" from "Inches"
    And I press the button to update demographic information
    Then I should be on the profile page for "Joe"
    And I should see "OK, your demographic information was updated."
    And "Feet" should have "6" selected
    And "Inches" should have "3" selected

  Scenario: User enters no height    
    When I press the button to update demographic information
    When I fill in "Weight" with "230"
    And I select "Male" from "Gender"
    And I select "1977-09-10" as the "Date of birth" date
    And I press the button to update demographic information

    Then I should be on the profile page for "Joe"
    And I should see "OK, your demographic information was updated."
    And "Feet" should have nothing selected
    And "Inches" should have nothing selected
    And "Gender" should have "Male" selected
    And "Weight" should have value "230"
    And "Year" should have "1977" selected
    And "Month" should have "9" selected
    And "Day" should have "10" selected
