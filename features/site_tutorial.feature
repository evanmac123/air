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
      | Alice in Wonderland | name: Hell on Wheels |
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
    When I follow "Next Slide"
    Then "Connect with Coworkers" should be visible
    When I follow "Directory"
    Then "Find Coworkers" should be visible
    When I fill in "search_string" with "Alice"
    And I press "Find!"
    
    Then I should see 'Click "Follow" to befriend Alice'
    When I click within ".follow-btn"
    Then I should see "Directory" 
    Then "Brand New" should have an open tutorial with current step "6" 
    
    
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
      
      