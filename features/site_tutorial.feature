Feature: Talking Chicken 
  Background: 
    Given the following demo exists:
      | name           |
      | Hell on Wheels | 
    Given the following rule exists:
      | points | demo                 |
      | 50     | name: Hell on Wheels |
    Given the following rule value exists:
      | rule          | value         | is_primary |
      | points: 50    | ate an orange | true       |
    Given the following brand new users exist:
      | name                | demo                 |
      | Brand New           | name: Hell on Wheels |
    Given "Brand New" has password "chicken"
    And I sign in via the login page as "Brand New/chicken"

  @javascript 
  Scenario: Talking Chicken does not pop up for new users
  And I wait a second
  Then I should see "Directory"
  And "Brand New" should not have any tutorials

  @javascript
  Scenario: Talking Chicken works all the way through
  And I wait a second
  Then I should see "Directory"
  When I go to the help page
  And I press "Take Quick Tour"
  Then "Brand New" should have an open tutorial with current step "0"
  And I should see "quick tour"
  When I click within ".show_tutorial"
  Then I should see "Directory"
  When I wait a second
  Then I should see "Say It!"
  When I wait a second
  And I fill in "command_central" with "some command you've never heard of"
  And I press "play_button"
  And I take five
  Then I should see "helpful info"
  When I click within "#next_button"
  Then I should see "Click DIRECTORY to find people you know"
  When I follow "Directory"
  Then I should see 'Just for practice, type "Kermit"'
  When I fill in "search_string" with "Kermit"
  And I press "Find!"
  And I wait a second
  Then I should see "Click ADD TO FRIENDS to connect with Kermit"
  When I click within ".follow-btn"
  Then I should see "Directory"
  And "Brand New" should have an open tutorial with current step "6"
  And I should see "Now you're connected with Kermit"
  When I follow "My Profile"
  Then I should see "Kermit the Frog"
  And "Brand New" should have an open tutorial with current step "7"
  When I take five
  And I follow "Finish"
  Then "Finish" should not be visible

  @javascript
  Scenario: Leah does not start tutorial
    And I wait a second
    When I go to the help page
    And I press "Take Quick Tour"
    Then "Brand New" should have an open tutorial with current step "0"
    And I should see "Directory"
    And I should see "quick tour"
    When I take five
    And I follow "No thanks"
    And I take five
    Then "No thanks" should not be visible
    And "Brand New" should have a closed tutorial with current step "0"
    When I go to the activity page
    And I take five
    Then I should not see "quick tour"
    When I sign out
    And I sign in via the login page as "Brand New/chicken"
    Then I should see "Directory"
    And "Brand New" should have a closed tutorial with current step "0"
    And I should not see "No thanks"

  @javascript
  Scenario: Leah leaves tutorial
    Then I should see "Directory"
    When I go to the help page
    And I press "Take Quick Tour"
    Then I should see "quick tour"
    When I click within ".show_tutorial"
    Then I should see "Directory"
    When I take five
    Then I should see "Say It!"
    When I click within "#gear"
    And I click within ".close_tutorial"
    Then I should see "Directory"
    And "Brand New" should have a closed tutorial with current step "1"
    When I take five
    Then "Say It!" should not be visible

      
