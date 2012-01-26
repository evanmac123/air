Feature: Admin edits bonus thresholds and rules

  Background:
    Given the following bonus thresholds exist:
      | min points | max points | award | demo                  |
      | 5          | 7          | 3     | name: FooCorp |
      | 11         | 15         | 5     | name: FooCorp |
    And the following levels exist:
      | name | threshold | demo                  |
      | N00b | 5         | name: FooCorp |
      | Pawn | 10        | name: FooCorp |
    And I sign in as an admin via the login page
    And I go to the admin "FooCorp" demo page
  
  Scenario: Admin edits bonus threshold
    When I follow "(edit bonus threshold)"
    And I fill in "Min points" with "18"
    And I fill in "Max points" with "25"
    And I fill in "Award" with "8"
    And I press "Update Bonus threshold"
    Then I should see "Bonus threshold updated"
    And I should see "Between 11 and 15 points: 5 points awarded (edit bonus threshold) Between 18 and 25 points: 8 points awarded"

  Scenario: Admin adds bonus threshold
    When I follow "Add bonus threshold"
    And I fill in "Min points" with "20"
    And I fill in "Max points" with "25"
    And I fill in "Award" with "6"
    And I press "Create Bonus threshold"
    Then I should see "Bonus threshold created"
    And I should see "Between 5 and 7 points: 3 points awarded (edit bonus threshold) Between 11 and 15 points: 5 points awarded (edit bonus threshold) Between 20 and 25 points: 6 points awarded"

  Scenario: Admin deletes bonus threshold
    When I press "Delete bonus threshold"
    Then I should be on the admin "FooCorp" demo page
    And I should see "Bonus threshold deleted"
    And I should not see "Between 5 and 7 points"

  Scenario: Admin edits bonus threshold with bad values
    When I follow "(edit bonus threshold)"
    And I fill in "Min points" with ""
    And I fill in "Max points" with "25"
    And I fill in "Award" with "8"
    And I press "Update Bonus threshold"
    Then I should see "Couldn't update bonus threshold: Min points can't be blank"
    And I should see "Between 5 and 7 points: 3 points awarded (edit bonus threshold) Between 11 and 15 points: 5 points awarded"

  Scenario: Admin tries to make bonus thresholds overlap
    When I follow "(edit bonus threshold)"
    And I fill in "Max points" with "13"
    And I press "Update Bonus threshold"
    Then I should see "Couldn't update bonus threshold: Max points of 13 would overlap with another threshold (11-15)"
    And I should see "Between 5 and 7 points: 3 points awarded (edit bonus threshold) Between 11 and 15 points: 5 points awarded"

  Scenario: Admin edits level
    When I follow "(edit level)"
    And I fill in "Name" with "Catching On"
    And I fill in "Threshold" with "15"
    And I press "Update Level"
    Then I should see "Level updated"
    And I should see "Pawn at 10 points (edit level) Catching On at 15 points"

  Scenario: Admin adds level
    When I follow "Add level"
    And I fill in "Name" with "N00b First Class"
    And I fill in "Threshold" with "8"
    And I press "Create Level"
    Then I should see "Level created"
    And I should see "N00b at 5 points (edit level) N00b First Class at 8 points (edit level) Pawn at 10 points"

  Scenario: Admin deletes level
    When I press "Delete level"
    Then I should be on the admin "FooCorp" demo page
    And I should see "Level deleted"
    And I should not see "N00b at 5 points"

  Scenario: Admin edits level with bad values
    When I follow "(edit level)"
    And I fill in "Name" with ""
    And I fill in "Threshold" with ""
    And I press "Update Level"
    Then I should see "Couldn't update level"
    And I should see "Name can't be blank"
    And I should see "Threshold can't be blank"
    And I should see "N00b at 5 points (edit level) Pawn at 10 points"

  Scenario: Admin attempts to make level with duplicate threshold
    When I follow "(edit level)"
    And I fill in "Threshold" with "10"
    And I press "Update Level"
    Then I should see "Couldn't update level"
    And I should see "Threshold has already been taken"
    And I should see "N00b at 5 points (edit level) Pawn at 10 points"
