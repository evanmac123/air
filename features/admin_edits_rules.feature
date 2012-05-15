Feature: Admin edits rules

  Background:
    Given the following levels exist:
      | name | threshold | demo                  |
      | N00b | 5         | name: FooCorp |
      | Pawn | 10        | name: FooCorp |
    And I sign in as an admin via the login page
    And I go to the admin "FooCorp" demo page
  
  Scenario: Admin edits level
    When I follow "(edit level)"
    And I fill in "Name" with "Catching On"
    And I fill in "Threshold" with "15"
    And I press "Update Level"
    Then I should see "Level updated"
    And I should see "2: Pawn at 10 points (edit level) 3: Catching On at 15 points"

  Scenario: Admin adds level
    When I follow "Add level"
    And I fill in "Name" with "N00b First Class"
    And I fill in "Threshold" with "8"
    And I press "Create Level"
    Then I should see "Level created"
    And I should see "2: N00b at 5 points (edit level) 3: N00b First Class at 8 points (edit level) 4: Pawn at 10 points"

  Scenario: Admin deletes level
    When I press "Delete level"
    Then I should be on the admin "FooCorp" demo page
    And I should see "Level deleted"
    And I should not see "N00b"
    But I should see "2: Pawn at 10 points"

  Scenario: Admin edits level with bad values
    When I follow "(edit level)"
    And I fill in "Name" with ""
    And I fill in "Threshold" with ""
    And I press "Update Level"
    Then I should see "Couldn't update level"
    And I should see "Name can't be blank"
    And I should see "Threshold can't be blank"
    And I should see "2: N00b at 5 points (edit level) 3: Pawn at 10 points"

  Scenario: Admin attempts to make level with duplicate threshold
    When I follow "(edit level)"
    And I fill in "Threshold" with "10"
    And I press "Update Level"
    Then I should see "Couldn't update level"
    And I should see "Threshold has already been taken"
    And I should see "2: N00b at 5 points (edit level) 3: Pawn at 10 points"
