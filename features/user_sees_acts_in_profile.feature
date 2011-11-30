Feature: A user's acts are shown in their profile

  @javascript
  Scenario: Looking at a user's profile
    Given the following demo exists:
      | company name |
      | FooCo        |
    And the following users exist:
      | name | demo                |
      | Joe  | company_name: FooCo |
      | Bob  | company_name: FooCo |
    And "Joe" has the password "foo"
    And the following acts exist:
      | text  | inherent points | user      |
      | did a | 1               | name: Bob |
      | did b | 1               | name: Bob |
      | did c | 1               | name: Bob |
      | did d | 1               | name: Bob |
      | did e | 1               | name: Bob |
      | did f | 1               | name: Bob |
      | did g | 1               | name: Bob |
      | did h | 1               | name: Bob |
      | did i | 1               | name: Bob |
      | did j | 1               | name: Bob |
      | did k | 1               | name: Bob |
    And I sign in via the login page with "Joe/foo"
    And I go to the profile page for "Bob"
    Then I should see "Bob did k"
    Then I should see "Bob did b"
    But I should not see "Bob did a"

    When I press the see more button within the activity stream
    Then I should see "Bob did k"
    And I should see "Bob did b"
    And I should see "Bob did a"
