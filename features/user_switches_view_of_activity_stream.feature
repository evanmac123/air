Feature: User filters their view of the activity stream

  Background:
    Given the following demo exists:
      | company name |
      | FooCo        |
    And the following users exist:
      | name | phone number | demo                |
      | Joe  | +14155551212 | company_name: FooCo |
      | Bob  | +14155551213 | company_name: FooCo |
      | Fred | +14155551214 | company_name: FooCo |
    And the following friendships exist:
      | user      | friend    |
      | name: Joe | name: Bob |
    And the following acts exist:
      | text         | user       |
      | ate kitten   | name: Joe  |
      | ate puppy    | name: Bob  |
      | ate duckling | name: Fred |
    And "Joe" has the password "foo"
    And I sign in via the login page with "Joe/foo"

  @javascript
  Scenario: User filters their view of the activity stream
    When I go to the activity page
    Then I should see "Joe ate kitten"
    And I should see "Bob ate puppy"
    And I should see "Fred ate duckling"
    And "All" should be the active act filter link

    When I follow "Fan Of" within the activity stream
    Then I should see "Bob ate puppy"
    And I should not see "Joe ate kitten"
    And I should not see "Fred ate duckling"
    And "Fan Of" should be the active act filter link

    When I follow "Mine" within the activity stream
    Then I should see "Joe ate kitten"
    And I should not see "Bob ate puppy"
    And I should not see "Fred ate duckling"
    And "Mine" should be the active act filter link

    When I follow "All" within the activity stream
    Then I should see "Joe ate kitten"
    And I should see "Bob ate puppy"
    And I should see "Fred ate duckling"
    And "All" should be the active act filter link

  @javascript
  Scenario: "See more" button follows filter currently in effect
    Given the following acts exist:
      | text             | user       |
      | ate 2 kittens    | name: Joe  |
      | ate 2 puppies    | name: Bob  |
      | ate 2 ducklings  | name: Fred |
      | ate 3 kittens    | name: Joe  |
      | ate 3 puppies    | name: Bob  |
      | ate 3 ducklings  | name: Fred |
      | ate 4 kittens    | name: Joe  |
      | ate 4 puppies    | name: Bob  |
      | ate 4 ducklings  | name: Fred |
      | ate 5 kittens    | name: Joe  |
      | ate 5 puppies    | name: Bob  |
      | ate 5 ducklings  | name: Fred |
      | ate 6 kittens    | name: Joe  |
      | ate 6 puppies    | name: Bob  |
      | ate 6 ducklings  | name: Fred |
      | ate 7 kittens    | name: Joe  |
      | ate 7 puppies    | name: Bob  |
      | ate 7 ducklings  | name: Fred |
      | ate 8 kittens    | name: Joe  |
      | ate 8 puppies    | name: Bob  |
      | ate 8 ducklings  | name: Fred |
      | ate 9 kittens    | name: Joe  |
      | ate 9 puppies    | name: Bob  |
      | ate 9 ducklings  | name: Fred |
      | ate 10 kittens   | name: Joe  |
      | ate 10 puppies   | name: Bob  |
      | ate 10 ducklings | name: Fred |
      | ate 11 kittens   | name: Joe  |
      | ate 11 puppies   | name: Bob  |
      | ate 11 ducklings | name: Fred |
    When I go to the activity page
    Then I should see "Fred ate 11 ducklings"
    And I should see "Bob ate 11 puppies"
    And I should see "Joe ate 11 kittens"
    And I should see "Fred ate 10 ducklings"
    And I should see "Bob ate 10 puppies"
    And I should see "Joe ate 10 kittens"
    And I should see "Fred ate 9 ducklings"
    And I should see "Bob ate 9 puppies"
    And I should see "Joe ate 9 kittens"
    And I should see "Fred ate 8 ducklings"
    But I should not see "Bob ate 8 puppies"
    And I should not see "Joe ate 8 kittens"

    When I press the see more button within the activity stream
    Then I should see "Fred ate 11 ducklings"
    And I should see "Bob ate 11 puppies"
    And I should see "Joe ate 11 kittens"
    And I should see "Fred ate 10 ducklings"
    And I should see "Bob ate 10 puppies"
    And I should see "Joe ate 10 kittens"
    And I should see "Fred ate 9 ducklings"
    And I should see "Bob ate 9 puppies"
    And I should see "Joe ate 9 kittens"
    And I should see "Fred ate 8 ducklings"
    And I should see "Bob ate 8 puppies"
    And I should see "Joe ate 8 kittens"
    And I should see "Fred ate 7 ducklings"
    And I should see "Bob ate 7 puppies"
    And I should see "Joe ate 7 kittens"
    And I should see "Fred ate 6 ducklings"
    And I should see "Bob ate 6 puppies"
    And I should see "Joe ate 6 kittens"
    And I should see "Fred ate 5 ducklings"
    And I should see "Bob ate 5 puppies"
    But I should not see "Joe ate 5 kittens"

    When I follow "Fan Of" within the activity stream
    Then I should see "Bob ate 11 puppies"
    And I should see "Bob ate 10 puppies"
    And I should see "Bob ate 9 puppies"
    And I should see "Bob ate 8 puppies"
    And I should see "Bob ate 7 puppies"
    And I should see "Bob ate 6 puppies"
    And I should see "Bob ate 5 puppies"
    And I should see "Bob ate 4 puppies"
    And I should see "Bob ate 3 puppies"
    And I should see "Bob ate 2 puppies"
    But I should not see "Bob ate puppy"
    And I should not see "Joe ate 11 kittens"
    And I should not see "Fred ate 11 ducklings"

    When I press the see more button within the activity stream
    Then I should see "Bob ate 11 puppies"
    And I should see "Bob ate 10 puppies"
    And I should see "Bob ate 9 puppies"
    And I should see "Bob ate 8 puppies"
    And I should see "Bob ate 7 puppies"
    And I should see "Bob ate 6 puppies"
    And I should see "Bob ate 5 puppies"
    And I should see "Bob ate 4 puppies"
    And I should see "Bob ate 3 puppies"
    And I should see "Bob ate 2 puppies"
    And I should see "Bob ate puppy"
    But I should not see "Joe ate 11 kittens"
    And I should not see "Fred ate 11 ducklings"

    When I follow "Mine" within the activity stream
    Then I should see "Joe ate 11 kittens"
    And I should see "Joe ate 10 kittens"
    And I should see "Joe ate 9 kittens"
    And I should see "Joe ate 8 kittens"
    And I should see "Joe ate 7 kittens"
    And I should see "Joe ate 6 kittens"
    And I should see "Joe ate 5 kittens"
    And I should see "Joe ate 4 kittens"
    And I should see "Joe ate 3 kittens"
    And I should see "Joe ate 2 kittens"
    But I should not see "Joe ate kitten"
    And I should not see "Bob ate 11 puppies"
    And I should not see "Fred ate 11 ducklings"

    When I press the see more button within the activity stream
    Then I should see "Joe ate 11 kittens"
    And I should see "Joe ate 10 kittens"
    And I should see "Joe ate 9 kittens"
    And I should see "Joe ate 8 kittens"
    And I should see "Joe ate 7 kittens"
    And I should see "Joe ate 6 kittens"
    And I should see "Joe ate 5 kittens"
    And I should see "Joe ate 4 kittens"
    And I should see "Joe ate 3 kittens"
    And I should see "Joe ate 2 kittens"
    And I should see "Joe ate kitten"
    But I should not see "Bob ate 11 puppies"
    And I should not see "Fred ate 11 ducklings"

    When I follow "All" within the activity stream
    Then I should see "Fred ate 11 ducklings"
    And I should see "Bob ate 11 puppies"
    And I should see "Joe ate 11 kittens"
    And I should see "Fred ate 10 ducklings"
    And I should see "Bob ate 10 puppies"
    And I should see "Joe ate 10 kittens"
    And I should see "Fred ate 9 ducklings"
    And I should see "Bob ate 9 puppies"
    And I should see "Joe ate 9 kittens"
    And I should see "Fred ate 8 ducklings"
    But I should not see "Bob ate 8 puppies"
    And I should not see "Joe ate 8 kittens"

    When I press the see more button within the activity stream
    Then I should see "Fred ate 11 ducklings"
    And I should see "Bob ate 11 puppies"
    And I should see "Joe ate 11 kittens"
    And I should see "Fred ate 10 ducklings"
    And I should see "Bob ate 10 puppies"
    And I should see "Joe ate 10 kittens"
    And I should see "Fred ate 9 ducklings"
    And I should see "Bob ate 9 puppies"
    And I should see "Joe ate 9 kittens"
    And I should see "Fred ate 8 ducklings"
    And I should see "Bob ate 8 puppies"
    And I should see "Joe ate 8 kittens"
    And I should see "Fred ate 7 ducklings"
    And I should see "Bob ate 7 puppies"
    And I should see "Joe ate 7 kittens"
    And I should see "Fred ate 6 ducklings"
    And I should see "Bob ate 6 puppies"
    And I should see "Joe ate 6 kittens"
    And I should see "Fred ate 5 ducklings"
    And I should see "Bob ate 5 puppies"
    But I should not see "Joe ate 5 kittens"
