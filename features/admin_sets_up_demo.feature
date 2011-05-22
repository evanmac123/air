Feature: Admin sets up demo

  Scenario: Admin sets up demo
    Given I am on the admin page
    When I follow "New Demo"
    And I fill in "Company name" with "3M"
    And I fill in "Victory threshold" with "100"
    And I fill in "Victory verification email" with "lucille@example.com"
    And I fill in "Victory verification SMS number" with "415-867-5309"
    And I fill in "Custom welcome message" with "3M will rule you all!"
    And I fill in "Custom victory achievement message" with "Congratulations as of %{winning_time}!"
    And I fill in "Custom victory SMS" with "You did it with %{points} points!"
    And I fill in "Custom victory scoreboard message" with "is the person!"
    And I fill in "Starting player score" with "5"
    And I select "2010" from "Year"
    And I select "May" from "Month"
    And I select "1" from "Day"
    And I select "12" from "Hour"
    And I select "00" from "Minute"
    And I press "Submit"
    Then I should be on the admin "3M" demo page
    And I should see "100 points to win"
    And I should see "Victory email to lucille@example.com"
    And I should see "Victory verification SMS to +14158675309"
    And I should see "Welcome message: 3M will rule you all!"
    And I should see "Victory achievement message: Congratulations as of %{winning_time}!"
    And I should see "Victory SMS: You did it with %{points} points!"
    And I should see "Victory scoreboard message: is the person!"
    And I should see "New players start with 5 points"
    And I should see "Game ends at May 01, 2010 at 08:00 AM Eastern"

  Scenario: Correct defaults
    Given I am on the admin page
    When I follow "New Demo"
    And I fill in "Company name" with "3M"
    And I press "Submit"
    Then I should see "Welcome message: You've joined the %{company_name} game! Your unique ID is %{unique_id} (text MYID if you forget). To play, text to this #."
    And I should see "Victory achievement message: You won on %{winning_time}. Congratulations!"
    And I should see "Victory SMS: Congratulations! You've got %{points} points and have qualified for the drawing!"
    And I should see "Victory scoreboard message: Won game!"
    And I should see "New players start with 0 points"
    And I should not see "points to win"
    And I should not see "Victory email to"
    And I should not see "Victory verification SMS to"
    And I should see "Game goes on indefinitely"

   Scenario: Admin adds user
     Given a demo exists with a company name of "3M"
     And I am on the admin "3M" demo page
     When I follow "Add new user"
     And I fill in "Name" with "Bobby Jones"
     And I fill in "Email" with "bobby@example.com"
     And I press "Submit"
     Then I should be on the admin "3M" demo page
     And I should see "Bobby Jones"
