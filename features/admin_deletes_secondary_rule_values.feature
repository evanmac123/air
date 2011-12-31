Feature: Admin deletes secondary rule values

  @javascript @slow
  Scenario: Admin deletes secondary rule values
    Given the following demo exists:
      | company name |
      | FooCo        |
    And the following rule exists:
      | reply | demo                |
      | Yeah. | company_name: FooCo |
    And the following rule values exist:
      | value | is primary | rule         |
      | foo   | true       | reply: Yeah. |
      | bar   | false      | reply: Yeah. |
      | baz   | false      | reply: Yeah. |
    And I sign in as an admin via the login page
    And I go to the admin rules page for "FooCo"
    And I follow "Edit Rule"
    And I follow "(show secondary values)"
    Then I should see an input with value "bar"

    When I press "Delete this rule"
    Then I should be on the rule edit page for "foo"
    And I should not see an input with value "bar"
