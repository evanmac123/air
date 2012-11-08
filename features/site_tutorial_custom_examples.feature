Feature: Talking Chicken 
  Background: 
    Given the following demo exists:
      | name               | example_tutorial | example_tooltip    |
      | Hell on Wheels     |                  |                    | 
      | Likes to Mix it Up | read a book      | jumped off a cliff |
    Given the following brand new users exist:
      | name                | demo                     |
      | Brand New           | name: Hell on Wheels     |
      | Old School          | name: Likes to Mix it Up |
    Given "Brand New" has password "chicken"
    And I sign in via the login page as "Brand New/chicken"
  
  
  @javascript 
  Scenario: Default text shows up
  And I wait a second
    Given "Brand New" has password "chicken"
    And I sign in via the login page as "Brand New/chicken"
  
    Then I should see "Directory"
    Then "Brand New" should have an open tutorial with current step "0"
    Given I close the facebox modal
    And I wait a second
    And I should see "quick tour"
    When I click within ".show_tutorial"
    And I should see "Directory"
    And I wait a second
    Then I should see "ate a banana"

  @javascript 
  Scenario: Custom text shows up
  And I wait a second
    Given "Old School" has password "foxylady"
    And I sign in via the login page as "Old School/foxylady"
    Then I should see "Directory"
    Then "Brand New" should have an open tutorial with current step "0"
    Given I close the facebox modal
    And I wait a second
    And I should see "quick tour"
    When I click within ".show_tutorial"
    And I should see "Directory"
    And I wait a second
    Then I should see "read a book"
