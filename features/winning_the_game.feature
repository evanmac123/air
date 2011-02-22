Feature: Player can win the game

# But not you. You just lost the game.

  Background: 
    Given the following user exists:
      | phone_number | points | demo                   |
      | +14155551212 | 97     | victory_threshold: 100 |
    And the following rule exists:
      | points | key       | value    | 
      | 3      | name: ate | a kitten |

  Scenario: Player wins by scoring enough points
    When "+14155551212" sends SMS "ate a kitten"
    Then "+14155551212" should have received an SMS "Congratulations! You've scored 100 points and won the game!"

  Scenario: Player wins just once
    When "+14155551212" sends SMS "ate a kitten"
    And "+14155551212" sends SMS "ate a kitten"
    Then "+14155551212" should have received an SMS "Congratulations! You've scored 100 points and won the game!"
    And "+14155551212" should not have received an SMS "Congratulations! You've scored 103 points and won the game!"
