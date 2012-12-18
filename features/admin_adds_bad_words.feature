Feature: Admin adds bad words

  Background:
    Given the following demos exist:
      | name   |
      | PrudeCo        |
      | Pantsville Inc |
    And the following bad words exist:
      | value        | demo                  |
      | gosh         |                       |
      | heck         |                       |
      | darn         |                       |
      | poot         | name: PrudeCo |
      | drat         | name: PrudeCo |
      | motherfucker | name: PrudeCo |
    And the following site admin exists:
      | name |
      | Bob  |
    And "Bob" has the password "foobar"
    And I sign in via the login page with "Bob/foobar"

  Scenario: Admin adds generic bad words
    When I go to the admin page
    And I follow "Bad Words"
    Then I should see "darn gosh heck"

    When I fill in "New bad words" with "feh, bah" 
    And I press "Add new bad words"
    Then I should be on the admin bad words page
    And I should see "bah darn feh gosh heck"

    When I press "Delete gosh"
    Then I should be on the admin bad words page
    And I should see "bah darn feh heck"

    When I go to the admin bad words page for "PrudeCo"
    Then I should see "drat motherfucker poot"

  Scenario: Admin adds demo-specific bad words
    When I go to the admin "PrudeCo" demo page
    And I follow "Bad words for this demo"
    Then I should see "drat motherfucker poot"    
    When I fill in "New bad words" with "feh, bah" 
    And I press "Add new bad words"
    Then I should be on the admin bad words page for "PrudeCo"
    And I should see "bah drat feh motherfucker poot"

    When I go to the admin page
    And I follow "Bad Words"
    Then I should see "darn gosh heck"

