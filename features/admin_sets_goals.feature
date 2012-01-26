Feature: Admin sets up goals
  Background:
    Given the following demo exists:
      | name |
      | GoalCo       |
    And the following goals exist:
      | name              | demo                 | achievement text   | completion sms text |
      | deadly sins       | name: GoalCo | Achieved deadly    | Completed deadly    |
      | redeeming virtues | name: GoalCo |                    |                     |
    And the following rules exist:
      | reply         | demo                 |
      | ok lust       | name: GoalCo |
      | ok wrath      | name: GoalCo |
      | ok sloth      | name: GoalCo |
      | ok chalk      | name: GoalCo |
      | ok cheese     | name: GoalCo |
      | ok charity    | name: GoalCo |
    And the rule "ok lust" is associated with the goal "deadly sins"
    And the rule "ok wrath" is associated with the goal "deadly sins"
    And the rule "ok sloth" is associated with the goal "deadly sins"
    And the rule "ok charity" is associated with the goal "redeeming virtues"
    And the following primary values exist:
      | value      | rule                 |
      | lust       | reply: ok lust       |
      | wrath      | reply: ok wrath      |
      | sloth      | reply: ok sloth      |
      | chalk      | reply: ok chalk      |
      | cheese     | reply: ok cheese     |
      | charity    | reply: ok charity    |
    And I sign in as an admin via the login page
    And I go to the admin "GoalCo" demo page
    And I follow "Goals for this demo"
    Then I should be on the admin goals page for "GoalCo"

  Scenario: Admin sees existing goals
    Then I should see "deadly sins"
    And I should see "Achievement text: Achieved deadly"
    And I should see "Completion SMS text: Completed deadly"
    And I should see "3 rules: lust sloth wrath"

  Scenario: Admin creates new goal
    When I follow "New Goal"
    Then I should not see "lust"
    And I should not see "wrath"
    And I should not see "pride"
    And I should not see "charity"

    And I fill in "Name" with "Cherries"
    And I fill in "Achievement text" with "Chose cheer"
    And I fill in "Completion SMS text" with "Changed chaps"
    And I select "chalk" from "Rules"
    And I select "cheese" from "Rules"
    And I press "Create Goal"

    Then I should be on the admin goals page for "GoalCo"
    And I should see "Cherries"
    And I should see "Chose cheer"
    And I should see "Changed chaps"
    And I should see "2 rules: chalk cheese"

  Scenario: Admin edits existing goal
    When I follow "(edit this goal)"
    Then I should see "lust" 
    And I should see "wrath"
    And I should see "sloth"
    And I should see "chalk"
    And I should see "cheese"
    But I should not see "charity"

    And I fill in "Name" with "awesome sins"
    And I fill in "Achievement text" with "Hooray for you"
    And I fill in "Completion SMS text" with "Whoop de doo"
    And I unselect "wrath" from "Rules"
    And I select "chalk" from "Rules"
    And I press "Update Goal"

    Then I should be on the admin goals page for "GoalCo"
    And I should see "awesome sins"
    And I should see "Achievement text: Hooray for you"
    And I should see "Completion SMS text: Whoop de doo"
    And I should see "3 rules: chalk lust sloth"

  Scenario: Admin deletes goal
    Given I should be on the admin goals page for "GoalCo"
    And I follow "(edit this goal)"
    And I press "Delete Goal"

    Then I should be on the admin goals page for "GoalCo"
    And I should not see "deadly sins"
    And I should not see "Achievement text: Achieved deadly"
    And I should not see "Completion SMS text: Completed deadly"
    And I should not see "3 rules: lust sloth wrath"

