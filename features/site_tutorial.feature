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
  Scenario: Talking Chicken pops first and foremost
  And I wait a second
    Then I should see "Directory"
    Then "Brand New" should have an open tutorial with current step "0"
    Given I close the facebox modal
    And I wait a second
    And I should see "quick tour"
    When I click within ".show_tutorial"
    And I should see "Directory"
    And I wait a second
    Then I should see "Say It!" 
    And I wait a second
    When I fill in "command_central" with "ate an orange"
    
    And I press "play_button"
    And I take five
    
    Then I should see "Your activity shows up here" 
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
    Then "Brand New" should have an open tutorial with current step "6" 
    And I should see "Now you're connected with Kermit"
    When I follow "My Profile"
    Then I should see "Kermit the Frog"
    Then "Brand New" should have an open tutorial with current step "7"
    And I take five
    When I follow "Finish"
    Then "Finish" should not be visible 
    
    
    @javascript
    Scenario: Leah does not start tutorial
      And I wait a second
      Then "Brand New" should have an open tutorial with current step "0"
      Then I should see "Directory"
      Given I close the facebox modal
      And I wait a second
      And I should see "quick tour"
      And I take five
      And I follow "No thanks"
      And I take five
      And "No thanks" should not be visible
      Then "Brand New" should have a closed tutorial with current step "0"
      And I go to the activity page
      And I take five
      Then I should not see "quick tour"
      And I sign out
      And I sign in via the login page as "Brand New/chicken"
      And I should see "Directory"
      Then "Brand New" should have a closed tutorial with current step "0"
      And I should not see "No thanks"
      
      
    
    @javascript 
    Scenario: Leah leaves tutorial
      Then I should see "Directory"
      Given I close the facebox modal
      And I wait a second
      And I should see "quick tour"
      When I click within ".show_tutorial"
      And I should see "Directory"
      And I take five
      Then I should see "Say It!"
      And I click within "#gear"
      And I click within ".close_tutorial"
      Then I should see "Directory"
      Then "Brand New" should have a closed tutorial with current step "1"
      And I take five
      Then "Say It!" should not be visible
      
    @javascript 
    Scenario: Leah leaves tutorial, then starts it again from FAQ
      Then I should see "Directory"
      Given I close the facebox modal
      And I wait a second
      And I should see "quick tour"
      When I click within ".show_tutorial"
      And I should see "Directory"
      And I take five
      Then I should see "Say It!"
      And I click within "#gear"
      And I click within ".close_tutorial"
      Then I should see "Directory"
      Then "Brand New" should have a closed tutorial with current step "1"
      And I take five
      Then "Say It!" should not be visible
      When I go to the help page
      And I press "Take Quick Tour"
      Then I should see "Directory"
      Then "Brand New" should have an open tutorial with current step "0"
      And I should be on the activity page
      And I should see "Welcome"
      
      
