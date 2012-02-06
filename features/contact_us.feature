Feature: User can contact us
  Background:
    Given the following user exists:
      | name   |
      | George |
    And "George" has password "foobar"
    And I sign in as "George/foobar"
  
  @javascript
  Scenario: I open the contact us modal
    When I follow "Help"
    Then I should see "Frequently Asked Questions"
    When I press "Contact Us"
    # Ideally, here I would check for content