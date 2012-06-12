Feature: Demos are kept separate
    
  Scenario: User logging in sees other users in the same demo
    Given the following user exists:
      | email           | name | demo             |
      | dan@example.com | Dan  | name: 3M | 
      
    And the following claimed users exist:
      | email           | name | privacy level | demo             |
      | bob@example.com | Bob  | everybody     | name: 3M         |
      | ned@example.com | Ned  | everybody     | name: Xe         |

    And the following acts exist:
      | text        | user      |
      | Did thing 1 | name: Bob |
      | Did thing 1 | name: Ned |

    And "Dan" has the password "foobar"

    When I sign in via the login page as "Dan/foobar"
    Then I should be on the activity page with HTML forced
    And I should see "Bob"
    But I should not see "Ned"
