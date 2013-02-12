Feature: Admin deletes secondary rule values

  @javascript @slow
  Scenario: Admin deletes secondary rule values
    Given the following demo exists:
      | name |
      | FooCo        |
    And the following rule exists:
      | reply | demo                |
      | Yeah. | name: FooCo |
    And the following rule values exist:
      | value | is primary | rule         |
      | foo   | true       | reply: Yeah. |
      | bar   | false      | reply: Yeah. |
      | baz   | false      | reply: Yeah. |
    And I sign in as an admin via the login page
    And I go to the admin rules page for "FooCo"
    And I follow "Edit Rule"
    Then I should see an input with value "bar"
    When I click the "Delete this rule" button for value "bar"
    Then I should be on the rule edit page for "foo"
    And I should not see an input with value "bar"
