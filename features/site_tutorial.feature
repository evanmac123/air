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
    Given the following claimed users exist:
      | name                | demo                 |
      | Brand New           | name: Hell on Wheels |
    Given "Brand New" has password "chicken"
    And I sign in via the login page as "Brand New/chicken"
  
  
  @javascript 
  Scenario: Talking Chicken pops first and foremost
  And I wait a second
    Then "Brand New" should have an open tutorial with current step "1"
    Then I should see "Directory"
    Given I close the facebox modal
    And I wait a second
    Then "Say It!" should be visible
    # When I fill in "command_central" with "took a walk"
    And I press "play_button"
    And I wait a second
    Then "Your activity shows up here" should be visible
    When I follow "Next"
    Then "Connect with Coworkers" should be visible
    When I follow "Directory"
    Then "Find Coworkers" should be visible
    When I fill in "search_string" with "Kermit"
    And I press "Find!"
    And I wait a second
    And show me the page
    
    Then I should see "Click 'Follow' to befriend Kermit"
    When I click within ".follow-btn"
    Then I should see "Directory" 
    Then "Brand New" should have an open tutorial with current step "6" 
    And "Click 'My Profile' to see who's following you" should be visible
    When I follow "My Profile"
    Then I should see "Kermit the Frog"
    
    @javascript 
    Scenario: User leaves tutorial
      Then I should see "Directory"
      Given I close the facebox modal
      And I wait a second
      Then "Brand New" should have an open tutorial with current step "1"
      And I click within "#gear"
      And I click within ".close_tutorial"
      Then I should see "Directory"
      Then "Brand New" should have a closed tutorial
      
      