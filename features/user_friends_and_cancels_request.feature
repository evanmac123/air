Feature: User approves or ignores follower


  Background:
    Given the following demo exists:
      | name                 |
      | Sweet Adeline        |
    And the following claimed users exist:
      | name  | email             | phone number | privacy level | demo        | session_count | gender |
      | Alice | alice@example.com | +14155551212 | everybody     | name: FooCo | 5             | female |
      | Clay  | clay@example.com  | +13055551212 | everybody     | name: FooCo | 5             | male   |

    And "Alice" has password "barley"
    And "Clay" has password "bazquux"

  Scenario: User decides to friend and changes mind and changes mind
    And I sign in via the login page with "Alice/barley"
    And I go to the user page for "Clay"
    And I press the button next to "Clay"
    Then I should see "OK, you'll be friends with Clay, pending his acceptance"
    And I press the button next to "Clay"
    Then I should see "Friendship request canceled"
    And I press the button next to "Clay"
    Then I should see "OK, you'll be friends with Clay, pending his acceptance"
    And "Clay" accepts "Alice" as a friend
    And I go to the user page for "Clay"
    Then I should see "already friends"
    And I press the button next to "Clay"
    And I should see "OK, you're no longer friends with Clay"
